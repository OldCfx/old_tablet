const container = document.getElementById('tabletContainer');
const frame = document.getElementById('tabletFrame');
const errorBox = document.getElementById('errorMsg');

const side = document.getElementById('sideToolbar');
const handle = document.getElementById('toolbarHandle');
const siteListEl = document.getElementById('siteList');

function setUrl(url) {
    errorBox.style.display = 'none';
    frame.style.display = 'block';
    frame.src = url;
}
function refreshFrame() {
    frame.src = frame.src;
}
function populateSiteButtons(sites) {
    siteListEl.innerHTML = '';
    if (!Array.isArray(sites) || sites.length === 0) {
        const empty = document.createElement('div');
        empty.style.opacity = '0.6';
        empty.textContent = 'Aucun site enregistré';
        siteListEl.appendChild(empty);
        return;
    }
    sites.forEach((url, i) => {
        const btn = document.createElement('button');
        btn.className = 'siteBtn';
        try {
            const u = new URL(url);
            btn.textContent = u.host.replace(/^www\./, '');
        } catch {
            btn.textContent = `Site ${i + 1}`;
        }
        btn.title = url;
        btn.addEventListener('click', () => setUrl(url));
        siteListEl.appendChild(btn);
    });
}

function closeTablet() {
    errorBox.style.display = 'none';
    frame.style.display = 'block';

    side.classList.remove('reveal');
    side.classList.remove('open');

    container.classList.remove('popIn');
    container.classList.add('popOut');
    container.onanimationend = () => {
        container.style.display = 'none';
        container.onanimationend = null;
    };

    fetch(`https://${GetParentResourceName()}/close`, { method: 'POST' });
}

side.addEventListener('click', (e) => {
    const btn = e.target.closest('button.toolBtn');
    if (!btn) return;
    const action = btn.dataset.action;
    if (action === 'close') return closeTablet();
    if (action === 'refresh') return refreshFrame();
});

let enterTimeout, leaveTimeout, revealTimeout;
let waitingReveal = false;

handle.addEventListener('pointerenter', () => {
    clearTimeout(leaveTimeout);
    clearTimeout(revealTimeout);

    if (!side.classList.contains('open')) {
        side.classList.add('open');
        waitingReveal = true;

        const onEnd = (e) => {
            if (e.propertyName !== 'width') return;
            side.removeEventListener('transitionend', onEnd);
            if (waitingReveal && side.classList.contains('open')) {
                side.classList.add('reveal');
                waitingReveal = false;
            }
        };
        side.addEventListener('transitionend', onEnd, { once: true });

        revealTimeout = setTimeout(() => {
            if (waitingReveal && side.classList.contains('open')) {
                side.classList.add('reveal');
                waitingReveal = false;
            }
        }, 80);
    } else {
        if (!side.classList.contains('reveal')) side.classList.add('reveal');
    }
});

side.addEventListener('pointerleave', () => {
    clearTimeout(revealTimeout);

    side.classList.remove('reveal');
    leaveTimeout = setTimeout(() => side.classList.remove('open'), 80);
});

handle.addEventListener('focus', () => {
    if (!side.classList.contains('open')) {
        side.classList.add('open');
        waitingReveal = true;
        revealTimeout = setTimeout(() => {
            if (waitingReveal) {
                side.classList.add('reveal');
                waitingReveal = false;
            }
        }, 80);
    }
});
side.addEventListener('focusout', (e) => {
    if (!side.contains(e.relatedTarget)) {
        side.classList.remove('reveal');
        side.classList.remove('open');
    }
});

window.addEventListener('message', (event) => {
    if (event.data.action === 'openTablet') {
        const { url, sites, uiSize } = event.data;

        container.style.display = 'flex';
        container.classList.remove('popOut');
        container.classList.add('popIn');

        const size = uiSize || 1.0;
        container.style.width = (60 * size) + "%";
        container.style.height = (50 * size) + "%";
        container.style.maxWidth = (800 * size) + "px";
        container.style.maxHeight = (600 * size) + "px";
        container.style.minWidth = (400 * size) + "px";
        container.style.minHeight = (300 * size) + "px";

        side.classList.remove('reveal');
        side.classList.remove('open');

        populateSiteButtons(sites || []);
        setUrl(url || sites?.[0] || 'about:blank');

        frame.onload = () => {
            try {
                const href = frame.contentWindow.location.href;
                if (!href || href === 'about:blank') {
                    frame.style.display = 'none';
                    errorBox.style.display = 'flex';
                }
            } catch {
                frame.style.display = 'none';
                errorBox.style.display = 'flex';
            }
        };
    }
});

document.addEventListener('keydown', (e) => {
    if (e.key === "Escape") closeTablet();
});