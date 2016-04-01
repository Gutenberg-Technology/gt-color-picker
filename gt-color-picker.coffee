angular.module('gt.colorpicker', []).directive 'gtColorPicker', ($parse) ->

    _hexToRgba = (color) ->
        if color.length is 4 # #eee vs #eeeeee
            colors = color.match(/[a-f0-9]/g).map (c) -> parseInt "#{c}#{c}", 16
        else colors = color.match(/[a-f0-9]{2}/g).map (c) -> parseInt c, 16
        return "rgba(#{ colors.join(', ') }, 1)"

    _rgbaToHex = (color) ->
        return '#' + color.match(/\d+/g).slice(0, 3)
            .map (c) -> parseInt(c, 10).toString(16)
            .join('')

    _rgbaStringToObject = (color) ->
        unless color? then color = 'rgba(0,0,0,1)'
        toReturn = color.replace('rgba(', '').replace(')', '').split(',')
        toReturn =
            r: +toReturn[0]
            g: +toReturn[1]
            b: +toReturn[2]
            a: +toReturn[3]
        return toReturn

    _rgbaObjectToString = (color) ->
        return "rgba(#{color.r},#{color.g},#{color.b},#{color.a})"

    restrict: 'E'
    replace: true
    scope:
        color: '='
        opacity: '@'
        showInput: '='
        inlinePicker: '='
    templateUrl: 'gt-color-picker.html'

    link: (scope, elem, attrs) ->

        if attrs.onchange
            onchangeHandler = $parse(attrs.onchange)
            scope.$watch 'color', ->
                onchangeHandler?(scope, { $color: scope.color })

        scope.isRgba = scope.opacity? and scope.opacity

        if scope.isRgba and scope.color?.indexOf('#') is 0
            scope.color = _hexToRgba scope.color
        else if not scope.isRgba and scope.color?.indexOf('rgba') is 0
            scope.color = _rgbaToHex scope.color

        _bodyClick = (e) ->
            target = e.target
            while target
                return if target.classList.contains 'gt-color-picker'
                return scope.toggle() if target.nodeName is 'BODY'
                target = target.parentElement

        _set = ->
            if scope.isRgba
                color = _rgbaStringToObject(scope.color)
                cp.setRgb(color or {r: 255, g: 255, b: 255, a: 1})
            else
                cp.setHex(scope.color or '#ffffff')


        _getCursor = -> elem[0].querySelector '.cursor'

        _updateCursor = (opacity) ->
            _getCursor().style.left = "#{opacity * 100}%"

        _updateOpacity = (opacity) ->
            _updateCursor(opacity)
            opacity = Math.round(opacity * 100) / 100
            scope.colorOpacity = opacity
            color = _rgbaStringToObject(scope.color)
            color.a = opacity
            scope.color = _rgbaObjectToString(color)
            scope.$evalAsync()

        slider = elem[0].querySelector '.alpha'
        sliderLeft = slider.getBoundingClientRect().left

        _cursorMove = (e) ->
            e.preventDefault()
            opacity = (e.x - sliderLeft) / slider.offsetWidth
            if opacity > 1 then opacity = 1
            if opacity < 0 then opacity = 0
            _updateOpacity(opacity)

        # Opacity
        if scope.isRgba
            color = _rgbaStringToObject(scope.color)
            opacity = color.a
            opacity = 1.0 if isNaN(opacity)
            _updateOpacity(opacity)

            slider.addEventListener 'mousedown', (e) ->
                e.preventDefault()
                e.stopPropagation()
                _release = ->
                    document.body.removeEventListener 'mousemove', _cursorMove
                    document.body.removeEventListener 'mouseup', _release
                document.body.addEventListener 'mousemove', _cursorMove
                document.body.addEventListener 'mouseup', _release

                _cursorMove(e)

        colorPicker = elem[0].querySelector '.color-picker-container .color-picker-color'

        scope.toggle = (e) ->
            e?.stopPropagation()
            return if attrs['disabled']
            scope.open = not scope.open
            if scope.open then document.body.addEventListener 'click', _bodyClick
            else document.body.removeEventListener 'click', _bodyClick
            scope.$evalAsync() unless e
            setTimeout _set, 100

        if scope.inlinePicker then scope.open = true

        cp = ColorPicker colorPicker, (hex, hsv, rgb) ->
            if scope.isRgba
                rgb.a = scope.colorOpacity
                scope.color = _rgbaObjectToString(rgb)
            else
                scope.color = hex
            scope.$evalAsync()
