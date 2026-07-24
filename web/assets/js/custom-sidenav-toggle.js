(function () {
    var btn = document.getElementById('iconNavbarSidenav');
    if (!btn) return;
    btn.addEventListener('click', function () {
        if (window.innerWidth >= 1200) {
            document.body.classList.toggle('sidenav-oculto-desktop');
        }
    });
})();
