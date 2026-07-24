(function () {
    var btn = document.getElementById('iconNavbarSidenav');
    if (!btn) return;
    btn.addEventListener('click', function () {
        if (window.innerWidth >= 1200) {
            document.body.classList.toggle('sidenav-oculto-desktop');
            // El script de Argon quita "bg-white" del sidenav 100ms despues
            // de este mismo click (pensado para cuando el menu queda fuera
            // de pantalla en movil). En escritorio el menu sigue visible,
            // asi que lo restauramos para que no quede transparente.
            var sidenav = document.getElementById('sidenav-main');
            if (sidenav) {
                setTimeout(function () {
                    sidenav.classList.add('bg-white');
                }, 150);
            }
        }
    });
})();
