function red (text) { return colorize(text, 'red') }
function green (text) { return colorize(text, 'green') }
function yellow (text) { return colorize(text, 'yellow') }
function blue (text) { return colorize(text, 'blue') }
function magenta (text) { return colorize(text, 'magenta') }
function cyan (text) { return colorize(text, 'cyan') }
function gray (text) { return colorize(text, 'gray') }

function colorize(text, color, style) {
    // color: 'red', 'green', 'blue'... (see below)
    // styles: 'normal' or undefined, 'bright', 'highlight'

    if (!style) {
        style = 'normal';
    }

    var _ansi = {
        csi: String.fromCharCode(0x1B) + '[',
        reset:      '0',
        text_prop:  'm',

        styles: {
            normal: '3',
            bright:     '9',
            highlight:  '4'
        },

        colors: {
            black:   '0',
            red:     '1',
            green:   '2',
            yellow:  '3',
            blue:    '4',
            magenta: '5',
            cyan:    '6',
            gray:    '7'
        }
    };

    var beginColor = _ansi.csi + _ansi.styles[style] + _ansi.colors[color] + _ansi.text_prop;
    var endColor = _ansi.csi + _ansi.reset + _ansi.text_prop;

    return beginColor + text + endColor;
}


// example
// print('see that ' + cyan('cyan') + ' color');
