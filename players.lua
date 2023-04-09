vlc_player = {
    player = '-p vlc',
    icon = scripts .. 'img/VLC.png',
    color = '0xFE8D08',
    params = {
        'title',
        'xesam:url',
        'mpris:length',
        'position',
        'duration(mpris:length - position)',
        'xesam:artist',
    },
}
plasma_browser_integration_player = {
    player = '-p plasma-browser-integration',
    icon = scripts .. 'img/nocover.png',
    color = 'new_gradient',
    params = {
        'title',
        'xesam:url',
        'mpris:length',
        'position',
        'duration(mpris:length - position)',
        'artist',
        'kde:mediaSrc',
        'mpris:artUrl',
    }
}
spotify_player = {
    player = '-p spotify',
    icon = scripts .. 'img/nocover.png',
    color = 'new_gradient',
    params = {
        'title',
        'xesam:url',
        'mpris:length',
        'position',
        'duration(mpris:length - position)',
        'artist',
        'kde:mediaSrc',
        'mpris:artUrl',
    }
}
another_player = {
    player = '',
    icon = scripts .. 'img/nocover.png',
    color = 'new_gradient',
    params = {
        'title',
        'xesam:url',
        'mpris:length',
        'position',
        'duration(mpris:length - position)',
        'artist',
        'kde:mediaSrc',
        'mpris:artUrl',
    }
}