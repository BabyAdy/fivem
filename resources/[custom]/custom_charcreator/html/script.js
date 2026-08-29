/* ============ Purple Havoc · Character Creator logic ============ */
(() => {
    const RES = (typeof GetParentResourceName === 'function') ? GetParentResourceName() : 'custom_charcreator';
    const post = (name, data = {}) =>
        fetch(`https://${RES}/${name}`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json; charset=UTF-8' },
            body: JSON.stringify(data),
        }).then(r => r.json().catch(() => ({}))).catch(() => ({}));

    const app = document.getElementById('app');
    const toast = document.getElementById('toast');
    const kicker = document.getElementById('kicker');
    const charname = document.getElementById('charname');
    const beardBlock = document.getElementById('beard-block');
    const confirmBtn = document.getElementById('btn-confirm');

    let limits = {};
    let state = null;
    let gender = 'male';
    let busy = false;

    /* ---------- path helpers ---------- */
    const getPath = (o, p) => p.split('.').reduce((a, k) => (a == null ? a : a[k]), o);
    const setPath = (o, p, v) => {
        const ks = p.split('.'); const last = ks.pop();
        ks.reduce((a, k) => (a[k] = a[k] || {}), o)[last] = v;
    };

    const LIMIT_KEY = {
        'heritage.mother': 'parent', 'heritage.father': 'parent',
        'heritage.resemblance': 'mix', 'heritage.skinTone': 'mix',
        'eyeColor': 'eyeColor',
        'hair.style': 'hair', 'hair.color': 'hairColor',
        'eyebrows.style': 'eyebrows', 'eyebrows.color': 'overlayColor',
        'beard.style': 'beard', 'beard.color': 'overlayColor',
    };
    const lim = (field) => limits[LIMIT_KEY[field]] || { min: 0, max: 100 };
    const clamp = (v, l) => Math.max(l.min, Math.min(l.max, v));

    const showToast = (msg, kind) => {
        toast.textContent = msg;
        toast.className = 'toast show ' + (kind || 'err');
        clearTimeout(showToast._t);
        showToast._t = setTimeout(() => (toast.className = 'toast'), 3800);
    };

    /* ---------- render one control from state ---------- */
    const renderStepper = (el) => {
        const field = el.dataset.stepper;
        const l = lim(field);
        let v = getPath(state, field);
        if (v == null) v = l.min;
        el.querySelector('.val').textContent = v;
        const pct = ((v - l.min) / Math.max(1, l.max - l.min)) * 100;
        el.querySelector('.bar i').style.width = Math.max(0, Math.min(100, pct)) + '%';
    };
    const renderSlider = (el) => {
        const field = el.dataset.slider;
        let v = getPath(state, field);
        if (v == null) v = 50;
        el.querySelector('input').value = v;
        el.querySelector('.val').textContent = v + '%';
    };
    const renderAll = () => {
        document.querySelectorAll('[data-stepper]').forEach(renderStepper);
        document.querySelectorAll('[data-slider]').forEach(renderSlider);
        beardBlock.classList.toggle('hidden', gender !== 'male');
    };

    /* ---------- steppers ---------- */
    document.querySelectorAll('[data-stepper]').forEach(el => {
        const field = el.dataset.stepper;
        const step = (dir) => {
            const l = lim(field);
            let v = getPath(state, field);
            if (v == null) v = l.min;
            v = clamp(v + dir, l);
            setPath(state, field, v);
            renderStepper(el);
            post('updateAppearance', { field, value: v }).then(r => {
                if (r && r.appearance) { state = r.appearance; }
            });
        };
        el.querySelector('.dec').addEventListener('click', () => step(-1));
        el.querySelector('.inc').addEventListener('click', () => step(1));
    });

    /* ---------- sliders ---------- */
    document.querySelectorAll('[data-slider]').forEach(el => {
        const field = el.dataset.slider;
        const input = el.querySelector('input');
        let t = null;
        input.addEventListener('input', () => {
            const v = parseInt(input.value, 10);
            el.querySelector('.val').textContent = v + '%';
            setPath(state, field, v);
            clearTimeout(t);
            t = setTimeout(() => post('updateAppearance', { field, value: v }), 40);
        });
    });

    /* ---------- tabs ---------- */
    document.getElementById('tabs').addEventListener('click', (e) => {
        const b = e.target.closest('.tab'); if (!b) return;
        document.querySelectorAll('.tab').forEach(t => t.classList.toggle('active', t === b));
        document.querySelectorAll('.tabpage').forEach(p => p.classList.toggle('active', p.dataset.page === b.dataset.tab));
    });

    /* ---------- gender ---------- */
    document.getElementById('gender').addEventListener('click', (e) => {
        const b = e.target.closest('button'); if (!b || busy) return;
        const g = b.dataset.gender;
        if (g === gender) return;
        document.querySelectorAll('#gender button').forEach(x => x.classList.toggle('active', x === b));
        post('setGender', { gender: g, view: currentView }).then(r => {
            if (r && r.appearance) { state = r.appearance; gender = r.gender || g; renderAll(); }
        });
    });

    /* ---------- stage cams / rotate / random ---------- */
    let currentView = 'body';
    document.getElementById('cams').addEventListener('click', (e) => {
        const b = e.target.closest('button'); if (!b) return;
        currentView = b.dataset.view;
        document.querySelectorAll('#cams button').forEach(x => x.classList.toggle('active', x === b));
        post('camera', { view: currentView });
    });
    document.getElementById('turn-l').addEventListener('click', () => post('rotate', { dir: -1 }));
    document.getElementById('turn-r').addEventListener('click', () => post('rotate', { dir: 1 }));
    document.getElementById('rand').addEventListener('click', () => {
        if (busy) return;
        post('randomize').then(r => { if (r && r.appearance) { state = r.appearance; renderAll(); } });
    });

    /* ---------- confirm / quit ---------- */
    confirmBtn.addEventListener('click', async () => {
        if (busy) return;
        busy = true; confirmBtn.classList.add('loading'); confirmBtn.disabled = true;
        const res = await post('confirm', {});
        if (!res || !res.status) {
            busy = false;
            confirmBtn.classList.remove('loading');
            confirmBtn.disabled = false;
            showToast((res && res.msg) || 'Eroare la crearea caracterului.', 'err');
            return;
        }
        showToast('Caracter creat! Intri în oraș…', 'ok');
        // client.lua closes the UI
    });
    document.getElementById('btn-quit').addEventListener('click', () => { if (!busy) post('quit'); });

    /* ---------- messages from client.lua ---------- */
    window.addEventListener('message', (ev) => {
        const d = ev.data || {};
        if (d.action === 'open') {
            limits = d.limits || {};
            state = d.appearance;
            gender = d.gender || 'male';

            kicker.textContent = d.mode === 'resume' ? 'Finalizează-ți contul' : 'Cont nou';
            charname.textContent = d.username || '—';

            document.querySelectorAll('#gender button').forEach(x => x.classList.toggle('active', x.dataset.gender === gender));
            renderAll();
            busy = false;
            confirmBtn.classList.remove('loading');
            confirmBtn.disabled = false;
            app.classList.remove('hidden');
        } else if (d.action === 'close') {
            app.classList.add('hidden');
            busy = false;
            confirmBtn.classList.remove('loading');
        }
    });

    if (typeof GetParentResourceName !== 'function') {
        // browser preview
        limits = { parent: { min: 0, max: 45 }, mix: { min: 0, max: 100 }, hair: { min: 0, max: 80 },
            hairColor: { min: 0, max: 63 }, eyebrows: { min: -1, max: 33 }, beard: { min: -1, max: 28 },
            overlayColor: { min: 0, max: 63 }, eyeColor: { min: 0, max: 31 } };
        state = { heritage: { mother: 0, father: 0, resemblance: 50, skinTone: 50 },
            hair: { style: 2, color: 8, highlight: 8 }, eyebrows: { style: 5, color: 8 },
            beard: { style: -1, color: 8 }, eyeColor: 0 };
        charname.textContent = 'DemoUser';
        renderAll();
        app.classList.remove('hidden');
    }
})();
