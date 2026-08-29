/* ============ Purple Havoc · Auth UI logic ============ */
(() => {
    const RES = (typeof GetParentResourceName === 'function') ? GetParentResourceName() : 'custom_auth';

    const app = document.getElementById('app');
    const card = document.getElementById('card');
    const tabs = document.querySelector('.tabs');
    const toast = document.getElementById('toast');
    const views = {
        login: document.getElementById('view-login'),
        register: document.getElementById('view-register'),
    };
    let rules = { usernameMin: 3, usernameMax: 24, passwordMin: 6, passwordMax: 64 };
    let busy = false;

    /* ---------- nui bridge ---------- */
    const post = (name, data = {}) =>
        fetch(`https://${RES}/${name}`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json; charset=UTF-8' },
            body: JSON.stringify(data),
        }).then(r => r.json().catch(() => ({}))).catch(() => ({}));

    /* ---------- helpers ---------- */
    const setHint = (form, field, msg, kind) => {
        const el = form.querySelector(`.hint[data-for="${field}"]`);
        const input = form.querySelector(`[name="${field}"]`);
        if (el) { el.textContent = msg || ''; el.className = 'hint' + (kind ? ' ' + kind : ''); }
        if (input) { input.classList.toggle('bad', kind === 'bad'); input.classList.toggle('good', kind === 'ok'); }
    };
    const clearHints = (form) => form.querySelectorAll('.hint').forEach(h => { h.textContent = ''; h.className = 'hint'; })
        || form.querySelectorAll('input').forEach(i => i.classList.remove('bad', 'good'));

    const showToast = (msg, kind) => {
        toast.textContent = msg;
        toast.className = 'toast show ' + (kind || 'err');
        clearTimeout(showToast._t);
        showToast._t = setTimeout(() => { toast.className = 'toast'; }, 4200);
    };

    const setBusy = (btn, on) => {
        busy = on;
        btn.classList.toggle('loading', on);
    };

    const shake = () => {
        card.classList.remove('shake');
        void card.offsetWidth;
        card.classList.add('shake');
    };

    /* ---------- tab switching ---------- */
    let current = 'login';
    const switchView = (name) => {
        if (name === current) return;
        current = name;
        tabs.dataset.view = name;
        tabs.querySelectorAll('.tab').forEach(t => t.classList.toggle('active', t.dataset.view === name));
        Object.entries(views).forEach(([k, v]) => v.classList.toggle('active', k === name));
        toast.className = 'toast';
    };
    tabs.querySelectorAll('.tab').forEach(t => t.addEventListener('click', () => switchView(t.dataset.view)));

    /* ---------- password show / hide ---------- */
    document.querySelectorAll('.toggle-pass').forEach(btn => {
        btn.addEventListener('click', () => {
            const input = document.getElementById(btn.dataset.target);
            input.type = input.type === 'password' ? 'text' : 'password';
        });
    });

    /* ---------- password strength (register) ---------- */
    const regPass = document.getElementById('reg-password');
    const strengthEl = document.querySelector('#view-register .strength');
    const scorePass = (v) => {
        let s = 0;
        if (v.length >= rules.passwordMin) s++;
        if (v.length >= 10) s++;
        if (/[A-Z]/.test(v) && /[a-z]/.test(v)) s++;
        if (/\d/.test(v) && /[^A-Za-z0-9]/.test(v)) s++;
        return Math.min(s, 4);
    };
    regPass.addEventListener('input', () => {
        strengthEl.dataset.lvl = regPass.value ? scorePass(regPass.value) : 0;
    });

    /* ---------- client-side validation ---------- */
    const vUser = (v) =>
        (v.length < rules.usernameMin || v.length > rules.usernameMax)
            ? `Între ${rules.usernameMin} și ${rules.usernameMax} caractere`
            : (!/^[\w.]+$/.test(v) ? 'Doar litere, cifre, _ și .' : null);
    const vEmail = (v) => /^[\w.\-]+@[\w.\-]+\.[A-Za-z]{2,}$/.test(v) ? null : 'Adresă de email invalidă';
    const vPass = (v) =>
        (v.length < rules.passwordMin || v.length > rules.passwordMax)
            ? `Între ${rules.passwordMin} și ${rules.passwordMax} caractere` : null;

    /* ---------- LOGIN submit ---------- */
    views.login.addEventListener('submit', async (e) => {
        e.preventDefault();
        if (busy) return;
        const form = views.login;
        clearHints(form);
        const username = form.username.value.trim();
        const password = form.password.value;
        let bad = false;
        if (!username) { setHint(form, 'username', 'Obligatoriu', 'bad'); bad = true; }
        if (!password) { setHint(form, 'password', 'Obligatoriu', 'bad'); bad = true; }
        if (bad) return shake();

        const btn = document.getElementById('btn-login');
        setBusy(btn, true);
        const res = await post('login', { username, password });
        setBusy(btn, false);

        if (!res || !res.status) {
            if (res && res.field) setHint(form, res.field, res.msg || 'Eroare', 'bad');
            showToast((res && res.msg) || 'Autentificare eșuată.', 'err');
            return shake();
        }
        showToast(res.msg || 'Bine ai revenit!', 'ok');
        lockUI();
    });

    /* ---------- REGISTER submit ---------- */
    views.register.addEventListener('submit', async (e) => {
        e.preventDefault();
        if (busy) return;
        const form = views.register;
        clearHints(form);
        const username = form.username.value.trim();
        const email = form.email.value.trim();
        const password = form.password.value;
        const confirmPassword = form.confirmPassword.value;

        let bad = false;
        const uErr = vUser(username); if (uErr) { setHint(form, 'username', uErr, 'bad'); bad = true; }
        const eErr = vEmail(email); if (eErr) { setHint(form, 'email', eErr, 'bad'); bad = true; }
        const pErr = vPass(password); if (pErr) { setHint(form, 'password', pErr, 'bad'); bad = true; }
        if (password !== confirmPassword) { setHint(form, 'confirmPassword', 'Parolele nu se potrivesc', 'bad'); bad = true; }
        if (bad) return shake();

        const btn = document.getElementById('btn-register');
        setBusy(btn, true);
        const res = await post('register', { username, email, password, confirmPassword });
        setBusy(btn, false);

        if (!res || !res.status) {
            if (res && res.field) setHint(form, res.field, res.msg || 'Eroare', 'bad');
            showToast((res && res.msg) || 'Înregistrare eșuată.', 'err');
            return shake();
        }
        showToast(res.msg || 'Cont creat! Se deschide creatorul de caracter…', 'ok');
        lockUI();
    });

    /* ---------- quit ---------- */
    document.getElementById('btn-quit').addEventListener('click', async () => {
        if (busy) return;
        await post('quit', {});
    });

    /* live field feedback on blur (register only) */
    views.register.username.addEventListener('blur', function () { const m = vUser(this.value.trim()); if (this.value) setHint(views.register, 'username', m || 'Disponibil', m ? 'bad' : 'ok'); });
    views.register.email.addEventListener('blur', function () { const m = vEmail(this.value.trim()); if (this.value) setHint(views.register, 'email', m || '', m ? 'bad' : 'ok'); });
    document.getElementById('reg-confirm').addEventListener('input', function () {
        if (!this.value) return setHint(views.register, 'confirmPassword', '', '');
        const ok = this.value === regPass.value;
        setHint(views.register, 'confirmPassword', ok ? 'Se potrivesc' : 'Nu se potrivesc', ok ? 'ok' : 'bad');
    });

    const lockUI = () => {
        busy = true;
        card.style.pointerEvents = 'none';
        card.style.filter = 'saturate(.8) brightness(.9)';
    };
    const unlockUI = () => {
        busy = false;
        card.style.pointerEvents = '';
        card.style.filter = '';
    };

    /* ---------- messages from client.lua ---------- */
    window.addEventListener('message', (ev) => {
        const d = ev.data || {};
        switch (d.action) {
            case 'open':
                if (d.rules) rules = Object.assign(rules, d.rules);
                unlockUI();
                app.classList.remove('hidden');
                setTimeout(() => {
                    const f = views[current].querySelector('input');
                    if (f) f.focus();
                }, 60);
                break;
            case 'close':
                app.classList.add('hidden');
                unlockUI();
                document.querySelectorAll('input').forEach(i => (i.value = ''));
                document.querySelectorAll('.hint').forEach(h => { h.textContent = ''; h.className = 'hint'; });
                toast.className = 'toast';
                break;
            case 'error':
                unlockUI();
                if (d.view) switchView(d.view);
                showToast(d.msg || 'Eroare.', 'err');
                shake();
                break;
        }
    });

    /* dev: show outside FiveM */
    if (typeof GetParentResourceName !== 'function') app.classList.remove('hidden');
})();
