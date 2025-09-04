const container = document.getElementById('tabletContainer');
const frame = document.getElementById('tabletFrame');
const errorBox = document.getElementById('errorMsg');
const closeBtn = document.getElementById('closeBtn');

window.addEventListener('message', (event) => {
    if (event.data.action === 'openTablet') {
        container.style.display = 'flex';
        container.classList.remove('popOut');
        container.classList.add('popIn');

        errorBox.style.display = 'none';
        frame.style.display = 'block';

        frame.src = event.data.url;

        frame.onload = () => {
            try {
                let href = frame.contentWindow.location.href;
                if (!href || href === "about:blank") {
                    frame.style.display = 'none';
                    errorBox.style.display = 'flex';
                }
            } catch (e) {
                frame.style.display = 'none';
                errorBox.style.display = 'flex';
            }
        };
    }
});

function closeTablet() {
    frame.removeAttribute("src");
    errorBox.style.display = 'none';
    frame.style.display = 'block';

    container.classList.remove('popIn');
    container.classList.add('popOut');

    container.onanimationend = () => {
        container.style.display = 'none';
        container.onanimationend = null;
    };

    fetch(`https://${GetParentResourceName()}/close`, { method: 'POST' });
}

closeBtn.addEventListener('click', () => {
    closeTablet();
});

document.addEventListener('keydown', (e) => {
    if (e.key === "Escape") {
        closeTablet();
    }
});
