angular.module('gt.colorpicker', []).directive('gtColorPicker', function($parse) {
  var _hexToRgba, _rgbaObjectToString, _rgbaStringToObject, _rgbaToHex;
  _hexToRgba = function(color) {
    var colors;
    if (color.length === 4) {
      colors = color.match(/[a-f0-9]/g).map(function(c) {
        return parseInt("" + c + c, 16);
      });
    } else {
      colors = color.match(/[a-f0-9]{2}/g).map(function(c) {
        return parseInt(c, 16);
      });
    }
    return "rgba(" + (colors.join(', ')) + ", 1)";
  };
  _rgbaToHex = function(color) {
    return '#' + color.match(/\d+/g).slice(0, 3).map(function(c) {
      return parseInt(c, 10).toString(16);
    }).join('');
  };
  _rgbaStringToObject = function(color) {
    var toReturn;
    if (color == null) {
      color = 'rgba(0,0,0,1)';
    }
    toReturn = color.replace('rgba(', '').replace(')', '').split(',');
    toReturn = {
      r: +toReturn[0],
      g: +toReturn[1],
      b: +toReturn[2],
      a: +toReturn[3]
    };
    return toReturn;
  };
  _rgbaObjectToString = function(color) {
    return "rgba(" + color.r + "," + color.g + "," + color.b + "," + color.a + ")";
  };
  return {
    restrict: 'E',
    replace: true,
    scope: {
      color: '=',
      opacity: '@',
      showInput: '=',
      inlinePicker: '='
    },
    templateUrl: 'gt-color-picker.html',
    link: function(scope, elem, attrs) {
      var _bodyClick, _cursorMove, _getCursor, _set, _updateCursor, _updateOpacity, color, colorPicker, cp, onchangeHandler, opacity, ref, ref1, slider, sliderLeft;
      if (attrs.onchange) {
        onchangeHandler = $parse(attrs.onchange);
        scope.$watch('color', function() {
          return typeof onchangeHandler === "function" ? onchangeHandler(scope, {
            $color: scope.color
          }) : void 0;
        });
      }
      scope.isRgba = (scope.opacity != null) && scope.opacity;
      if (scope.isRgba && ((ref = scope.color) != null ? ref.indexOf('#') : void 0) === 0) {
        scope.color = _hexToRgba(scope.color);
      } else if (!scope.isRgba && ((ref1 = scope.color) != null ? ref1.indexOf('rgba') : void 0) === 0) {
        scope.color = _rgbaToHex(scope.color);
      }
      _bodyClick = function(e) {
        var target;
        target = e.target;
        while (target) {
          if (target.classList.contains('gt-color-picker')) {
            return;
          }
          if (target.nodeName === 'BODY') {
            return scope.toggle();
          }
          target = target.parentElement;
        }
      };
      _set = function() {
        var color;
        if (scope.isRgba) {
          color = _rgbaStringToObject(scope.color);
          return cp.setRgb(color || {
            r: 255,
            g: 255,
            b: 255,
            a: 1
          });
        } else {
          return cp.setHex(scope.color || '#ffffff');
        }
      };
      _getCursor = function() {
        return elem[0].querySelector('.cursor');
      };
      _updateCursor = function(opacity) {
        return _getCursor().style.left = (opacity * 100) + "%";
      };
      _updateOpacity = function(opacity) {
        var color;
        _updateCursor(opacity);
        opacity = Math.round(opacity * 100) / 100;
        scope.colorOpacity = opacity;
        color = _rgbaStringToObject(scope.color);
        color.a = opacity;
        scope.color = _rgbaObjectToString(color);
        return scope.$evalAsync();
      };
      slider = elem[0].querySelector('.alpha');
      sliderLeft = slider.getBoundingClientRect().left;
      _cursorMove = function(e) {
        var opacity;
        e.preventDefault();
        opacity = (e.x - sliderLeft) / slider.offsetWidth;
        if (opacity > 1) {
          opacity = 1;
        }
        if (opacity < 0) {
          opacity = 0;
        }
        return _updateOpacity(opacity);
      };
      if (scope.isRgba) {
        color = _rgbaStringToObject(scope.color);
        opacity = color.a;
        if (isNaN(opacity)) {
          opacity = 1.0;
        }
        _updateOpacity(opacity);
        slider.addEventListener('mousedown', function(e) {
          var _release;
          e.preventDefault();
          e.stopPropagation();
          _release = function() {
            document.body.removeEventListener('mousemove', _cursorMove);
            return document.body.removeEventListener('mouseup', _release);
          };
          document.body.addEventListener('mousemove', _cursorMove);
          document.body.addEventListener('mouseup', _release);
          return _cursorMove(e);
        });
      }
      colorPicker = elem[0].querySelector('.color-picker-container .color-picker-color');
      scope.toggle = function(e) {
        if (e != null) {
          e.stopPropagation();
        }
        if (attrs['disabled']) {
          return;
        }
        scope.open = !scope.open;
        if (scope.open) {
          document.body.addEventListener('click', _bodyClick);
        } else {
          document.body.removeEventListener('click', _bodyClick);
        }
        if (!e) {
          scope.$evalAsync();
        }
        return setTimeout(_set, 100);
      };
      if (scope.inlinePicker) {
        scope.open = true;
      }
      return cp = ColorPicker(colorPicker, function(hex, hsv, rgb) {
        if (scope.isRgba) {
          rgb.a = scope.colorOpacity;
          scope.color = _rgbaObjectToString(rgb);
        } else {
          scope.color = hex;
        }
        return scope.$evalAsync();
      });
    }
  };
});

angular.module('gt.colorpicker').run(['$templateCache', function($templateCache) {$templateCache.put('gt-color-picker.html','<div class="gt-color-picker" ng-class="{ \'color-picker-inline\':inlinePicker }"><div ng-hide="inlinePicker" ng-click="toggle($event)" class="color-picker-button" ng-style="{ \'background\': color }"></div><div class="color-picker-container" ng-show="open"><div class="color-picker-color"></div><div class="color-picker-alpha"><div class="alpha-value" ng-bind="colorOpacity"></div><div class="alpha-label" ng-show="isRgba" translate="OPACITY"></div><div class="alpha" ng-show="isRgba"><div class="cursor"></div></div></div><input type="text" ng-model="color" ng-show="showInput"></div></div>');}]);