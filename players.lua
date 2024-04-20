players = {
    {
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
    },
    {
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
    },
    {
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
    },
    {
        player = '-p org.telegram.desktop metadata',
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
    },
    {
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
}
