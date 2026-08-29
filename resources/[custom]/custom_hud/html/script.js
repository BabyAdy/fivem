(() => {
    const isGame = typeof GetParentResourceName === 'function';
    const $ = (id) => document.getElementById(id);
    const hud = $('hud');

    const state = { cash: { s: 0, t: 0 }, bank: { s: 0, t: 0 }, pp: { s: 0, t: 0 } };
    let cfg = { speedUnit: 'kmh', floatMs: 1500 };
    let paycheckLeft = null;

    const groups = (n) => Math.round(n).toString().replace(/\B(?=(\d{3})+(?!\d))/g, ',');
    const fmt = { cash: (n) => '$' + groups(n), bank: (n) => '$' + groups(n), pp: (n) => groups(n) };

    // count-up
    function tick() {
        for (const k of ['cash', 'bank', 'pp']) {
            const o = state[k];
            if (o.s !== o.t) {
                const d = o.t - o.s;
                o.s = Math.abs(d) < 1 ? o.t : o.s + (Math.abs(d * 0.16) < 1 ? Math.sign(d) : d * 0.16);
                $('v-' + k).textContent = fmt[k](o.s);
            }
        }
        requestAnimationFrame(tick);
    }
    requestAnimationFrame(tick);
    const setT = (k, v) => { v = Number(v) || 0; if (state[k].t !== v) state[k].t = v; };

    function spawnFloat(k, delta, neutral) {
        const box = $('f-' + k); if (!box) return;
        const el = document.createElement('div');
        el.className = 'flt ' + (neutral ? 'neu' : (delta >= 0 ? 'pos' : 'neg')) + (k === 'pp' ? ' pp' : '');
        const sign = neutral ? '' : (delta >= 0 ? '+' : '−');
        el.textContent = sign + (k === 'pp' ? groups(Math.abs(delta)) : '$' + groups(Math.abs(delta)));
        box.appendChild(el);
        setTimeout(() => el.remove(), cfg.floatMs + 300);
        const row = box.closest('.m-row');
        if (row) { row.classList.remove('bump'); void row.offsetWidth; row.classList.add('bump'); }
    }

    function setBar(id, pct, label) {
        const sec = $(id); if (!sec) return;
        pct = Math.max(0, Math.min(100, Math.round(pct)));
        sec.querySelector('.fill').style.width = pct + '%';
        if (label) $(label).textContent = pct + '%';
    }

    function applyShield(staff) {
        const sec = $('shield');
        if (!staff || !staff.color || staff.rank === 'none') { sec.classList.add('hidden'); return; }
        document.documentElement.style.setProperty('--shield', staff.color);
        $('shieldLabel').textContent = staff.label || staff.rank;
        sec.classList.remove('hidden');
    }

    function pcTxt(sec) {
        if (sec == null || sec < 0) return '--:--';
        const m = Math.floor(sec / 60), s = Math.floor(sec % 60);
        return String(m).padStart(2, '0') + ':' + String(s).padStart(2, '0');
    }
    setInterval(() => {
        if (paycheckLeft != null && paycheckLeft > 0) { paycheckLeft--; $('paycheck').textContent = pcTxt(paycheckLeft); }
    }, 1000);

    const toggleIco = (id, on) => $(id) && $(id).classList.toggle('on', !!on);
    function updateVehicle(d) {
        $('spd').textContent = d.speed;
        $('spdUnit').textContent = d.unit === 'mph' ? 'mph' : 'km/h';
        $('gear').textContent = d.gear;
        $('rpmBar').style.width = Math.round((d.rpm || 0) * 100) + '%';
        $('fuelBar').style.width = (d.fuel || 0) + '%';
        $('fuelTxt').textContent = d.fuel;
        $('engBar').style.width = (d.engine || 0) + '%';
        const belt = $('i-belt');
        belt.classList.toggle('on', d.belt); belt.classList.toggle('off', !d.belt);
        belt.textContent = d.belt ? '🔒' : '🔓';
        toggleIco('i-lights', d.lights > 0);
        $('i-lights').textContent = d.lights === 2 ? '🔦' : '💡';
        toggleIco('i-cruise', d.cruise);
        $('i-nitro').classList.toggle('hidden', d.nitro < 0);
        $('i-nitro').classList.toggle('on', d.nitro > 0);
        $('i-harness').classList.toggle('hidden', d.harness < 0);
        $('i-harness').classList.toggle('on', d.harness > 0);
        toggleIco('i-lock', d.locked);
    }

    window.addEventListener('message', (ev) => {
        const d = ev.data || {};
        switch (d.action) {
            case 'init':
                $('pname').textContent = d.name || '—';
                $('pid').textContent = (d.id != null) ? '[ID: ' + d.id + ']' : '';
                if (d.serverName) $('srvname').textContent = d.serverName;
                state.pp.s = state.pp.t = d.pp || 0; $('v-pp').textContent = fmt.pp(d.pp || 0);
                applyShield(d.staff);
                cfg = Object.assign(cfg, d.cfg || {});
                if (d.cfg && d.cfg.showShield === false) $('shield').classList.add('hidden');
                $('botleft').classList.toggle('hidden', d.cfg && d.cfg.showVitals === false);
                hud.classList.remove('hidden');
                break;

            case 'status': {
                const s = d.data || {};
                setT('cash', s.cash); setT('bank', s.bank);
                setBar('b-health', s.health, 'hpPct');
                setBar('b-armor', s.armor, 'arPct');
                setBar('b-food', s.hunger, 'fdPct');
                setBar('b-water', s.thirst, 'wtPct');
                $('b-oxygen').classList.toggle('hidden', !s.inWater);
                setBar('b-oxygen', s.oxygen, 'oxPct');
                $('clock').textContent = s.clock || '00:00';
                $('mic').classList.toggle('on', !!s.talking);
                break;
            }

            case 'serverInfo':
                if (d.online != null) $('pcount').textContent = d.online;
                break;

            case 'paycheck':
                paycheckLeft = Math.max(0, Math.floor(d.seconds ?? -1));
                $('paycheck').textContent = pcTxt(paycheckLeft);
                break;

            case 'money':
                spawnFloat(d.kind, d.delta);
                break;
            case 'pp':
                setT('pp', d.value);
                if (d.delta) spawnFloat('pp', d.delta);
                break;
            case 'accountPopup':
                spawnFloat(d.kind === 'bank' ? 'bank' : 'cash', d.amount, true);
                break;

            case 'vehicle':
                if (d.inVehicle && cfg.showVehicle !== false) { $('speedo').classList.remove('hidden'); updateVehicle(d.data || {}); }
                else $('speedo').classList.add('hidden');
                break;

            case 'visible':
                hud.classList.toggle('hud-off', !d.state);
                break;
        }
    });

    if (!isGame) {
        window.postMessage({ action: 'init', name: 'BabyAdy', id: 42, serverName: 'PURPLE HAVOC', pp: 1250,
            staff: { rank: 'headadmin', color: '#FF6A00', label: 'Head Admin' }, cfg: { showShield: true, showVehicle: true } }, '*');
        window.postMessage({ action: 'serverInfo', online: 155 }, '*');
        window.postMessage({ action: 'paycheck', seconds: 696 }, '*');
        window.postMessage({ action: 'status', data: { cash: 811546, bank: 5996785, health: 40, armor: 65, hunger: 79, thirst: 79, oxygen: 100, inWater: false, talking: true, clock: '10:02' } }, '*');
        window.postMessage({ action: 'vehicle', inVehicle: true, data: { speed: 132, unit: 'kmh', gear: 5, rpm: 0.8, fuel: 54, engine: 91, belt: false, cruise: true, lights: 1, nitro: -1, harness: -1, locked: true } }, '*');
        setTimeout(() => window.postMessage({ action: 'money', kind: 'cash', delta: 1500 }, '*'), 800);
        setTimeout(() => window.postMessage({ action: 'money', kind: 'bank', delta: -32000 }, '*'), 1500);
        setTimeout(() => window.postMessage({ action: 'pp', value: 1300, delta: 50 }, '*'), 2200);
    }
})();
