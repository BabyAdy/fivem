(() => {
    const RES = (typeof GetParentResourceName === 'function') ? GetParentResourceName() : 'custom_chat';
    const post = (name, data = {}) =>
        fetch(`https://${RES}/${name}`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json; charset=UTF-8' },
            body: JSON.stringify(data),
        }).catch(() => {});

    const chat = document.getElementById('chat');
    const log = document.getElementById('log');
    const composer = document.getElementById('composer');
    const input = document.getElementById('input');
    const prefixEl = document.getElementById('prefix');
    const sugBox = document.getElementById('suggestions');

    const MAX_LINES = 150;
    const RECENT_MS = 12000;
    let recentTimer = null;
    let open = false;
    let suggestions = [];
    let sugFiltered = [];
    let sugIndex = -1;
    const history = [];
    let histIndex = -1;

    const CONSOLE = ['#FFFFFF', '#F0463C', '#4CD07D', '#FFE14D', '#4FA8FF', '#37D7E3',
        '#B98BFF', '#FFFFFF', '#FF8A3D', '#9E9AAE'];

    /* ── colour-code parser (^#rrggbb / ^#rgb / ^0-^9 / ^r) ── */
    function parseColored(str, base) {
        const segs = [];
        let color = base || null, buf = '', i = 0;
        const flush = () => { if (buf) segs.push({ text: buf, color }); buf = ''; };
        str = String(str || '');
        while (i < str.length) {
            if (str[i] === '^') {
                const n = str[i + 1];
                if (n === '#') {
                    let hex = str.slice(i + 2, i + 8);
                    if (/^[0-9a-fA-F]{6}$/.test(hex)) { flush(); color = '#' + hex; i += 8; continue; }
                    hex = str.slice(i + 2, i + 5);
                    if (/^[0-9a-fA-F]{3}$/.test(hex)) { flush(); color = '#' + hex; i += 5; continue; }
                } else if (n >= '0' && n <= '9') { flush(); color = CONSOLE[+n]; i += 2; continue; }
                else if (n === 'r' || n === 'R') { flush(); color = base || null; i += 2; continue; }
            }
            buf += str[i++];
        }
        flush();
        return segs;
    }

    function appendSegments(parent, str) {
        for (const seg of parseColored(str)) {
            const s = document.createElement('span');
            s.textContent = seg.text;           // safe: no HTML injection
            if (seg.color) s.style.color = seg.color;
            parent.appendChild(s);
        }
    }

    function addLine(header, body) {
        const wasBottom = log.scrollTop + log.clientHeight >= log.scrollHeight - 8;
        const line = document.createElement('div');
        line.className = 'line';
        appendSegments(line, header || '');
        if (header && body !== '' && body != null) {
            const sep = document.createElement('span');
            sep.className = 'sep';
            sep.textContent = ': ';
            line.appendChild(sep);
        }
        if (body != null && body !== '') appendSegments(line, body);
        log.appendChild(line);
        while (log.children.length > MAX_LINES) log.removeChild(log.firstChild);
        if (!open || wasBottom) log.scrollTop = log.scrollHeight;

        chat.classList.add('recent');
        chat.classList.remove('idle');
        clearTimeout(recentTimer);
        recentTimer = setTimeout(() => {
            if (!open) { chat.classList.remove('recent'); chat.classList.add('idle'); }
        }, RECENT_MS);
    }

    /* keep hammering focus until the caret is actually in the input — a single
       delayed focus() often loses the race with the NUI frame becoming focusable */
    function focusInput() {
        let tries = 0;
        const grab = () => {
            try {
                input.focus({ preventScroll: true });
                input.setSelectionRange(input.value.length, input.value.length);
            } catch (e) {}
            if (open && document.activeElement !== input && tries++ < 30) {
                requestAnimationFrame(grab);
            }
        };
        grab();
        requestAnimationFrame(grab);
        setTimeout(grab, 50);
        setTimeout(grab, 150);
        setTimeout(grab, 300);
    }

    /* ── composer open / close ── */
    function openComposer(prefill) {
        open = true;
        chat.classList.add('active');
        chat.classList.remove('idle');
        composer.classList.remove('hidden');
        input.value = prefill || '';
        histIndex = -1;
        updatePrefix();
        refreshSuggestions();
        focusInput();
        log.scrollTop = log.scrollHeight;
    }
    function closeComposer(send) {
        const text = input.value.trim();
        open = false;
        chat.classList.remove('active');
        composer.classList.add('hidden');
        sugBox.classList.add('hidden');
        input.value = '';
        prefixEl.textContent = '';
        log.scrollTop = log.scrollHeight;   // snap back to newest on close
        if (send && text) {
            history.unshift(text);
            if (history.length > 40) history.pop();
            post('send', { text });
        }
        post('close');
        clearTimeout(recentTimer);
        chat.classList.add('recent');
        recentTimer = setTimeout(() => { chat.classList.remove('recent'); chat.classList.add('idle'); }, RECENT_MS);
    }

    function updatePrefix() {
        const v = input.value;
        if (v.startsWith('/')) { prefixEl.textContent = ''; }
        else { prefixEl.textContent = ''; }
    }

    /* ── suggestions ── */
    function refreshSuggestions() {
        const v = input.value;
        if (!v.startsWith('/') || v.includes(' ')) { sugBox.classList.add('hidden'); sugFiltered = []; sugIndex = -1; return; }
        const q = v.toLowerCase();
        sugFiltered = suggestions.filter(s => s.name.toLowerCase().startsWith(q));
        if (!sugFiltered.length) { sugBox.classList.add('hidden'); sugIndex = -1; return; }
        sugIndex = 0;
        renderSuggestions();
        sugBox.classList.remove('hidden');
    }
    function renderSuggestions() {
        sugBox.innerHTML = '';
        sugFiltered.slice(0, 8).forEach((s, i) => {
            const el = document.createElement('div');
            el.className = 'sug' + (i === sugIndex ? ' active' : '');
            const name = document.createElement('span'); name.className = 's-name'; name.textContent = s.name;
            el.appendChild(name);
            if (s.help) { const h = document.createElement('span'); h.className = 's-help'; h.textContent = s.help; el.appendChild(h); }
            if (s.params && s.params.length) {
                const a = document.createElement('span'); a.className = 's-args';
                s.params.forEach(p => {
                    const b = document.createElement('b'); b.textContent = '[' + p.name + '] ';
                    a.appendChild(b);
                    a.appendChild(document.createTextNode((p.help || '') + '  '));
                });
                el.appendChild(a);
            }
            el.addEventListener('mousedown', (ev) => { ev.preventDefault(); input.value = s.name + ' '; refreshSuggestions(); input.focus(); });
            sugBox.appendChild(el);
        });
    }

    input.addEventListener('input', () => { updatePrefix(); refreshSuggestions(); });

    input.addEventListener('keydown', (e) => {
        if (e.key === 'Enter') {
            e.preventDefault();
            if (sugFiltered.length && sugIndex >= 0 && !input.value.includes(' ')) {
                input.value = sugFiltered[sugIndex].name + ' ';
                refreshSuggestions();
                return;
            }
            closeComposer(true);
        } else if (e.key === 'Escape') {
            e.preventDefault();
            closeComposer(false);
        } else if (e.key === 'ArrowUp') {
            if (sugFiltered.length) { e.preventDefault(); sugIndex = (sugIndex - 1 + sugFiltered.length) % sugFiltered.length; renderSuggestions(); }
            else if (history.length) { e.preventDefault(); histIndex = Math.min(histIndex + 1, history.length - 1); input.value = history[histIndex] || ''; }
        } else if (e.key === 'ArrowDown') {
            if (sugFiltered.length) { e.preventDefault(); sugIndex = (sugIndex + 1) % sugFiltered.length; renderSuggestions(); }
            else if (histIndex > 0) { e.preventDefault(); histIndex--; input.value = history[histIndex] || ''; }
            else if (histIndex === 0) { e.preventDefault(); histIndex = -1; input.value = ''; }
        } else if (e.key === 'Tab') {
            e.preventDefault();
            if (sugFiltered.length && sugIndex >= 0) { input.value = sugFiltered[sugIndex].name + ' '; refreshSuggestions(); }
        }
    });

    /* ── messages from client.lua ── */
    window.addEventListener('message', (ev) => {
        const d = ev.data || {};
        switch (d.type) {
            case 'msg':
                addLine(d.header || '', d.body != null ? d.body : '');
                break;
            case 'open':
                openComposer(d.prefill || '');
                break;
            case 'close':
                if (open) closeComposer(false);
                break;
            case 'clear':
                log.innerHTML = '';
                break;
            case 'suggestions':
                suggestions = Array.isArray(d.list) ? d.list : [];
                if (open) refreshSuggestions();
                break;
        }
    });

    /* ── browser preview ── */
    if (typeof GetParentResourceName !== 'function') {
        addLine('^#8A8698' + '12:04 ' + '^#FFFFFF[7]BabyAdy', '^#FFFFFFsalut, cum merge?');
        addLine('^#8A8698' + '12:05 ' + '^#B57BFF(/pc)[7]^#C300FF[Legend]^#B57BFFBabyAdy', '^#B57BFFvand camber ticket');
        addLine('^#8A8698' + '12:06 ' + '^#FFA64D(/a)[7]^#5100FF[Owner]^#FFA64DBabyAdy', '^#FFA64Dcine e online din staff?');
        chat.classList.remove('idle'); chat.classList.add('recent');
        suggestions = [{ name: '/pc', help: 'Chat premium', params: [{ name: 'mesaj', help: 'text' }] }];
    }
})();
