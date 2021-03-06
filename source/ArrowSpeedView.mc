using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;

class ArrowSpeedView extends WatchUi.DataField {

    const STATUTE_UNIT_FACTOR = 0.621371f;
    const MAX_PADDING = 10;

    hidden var value = "__._";
    hidden var faster = null;
    hidden var fontUnits = Graphics.FONT_TINY;
    hidden var arrows;

    function initialize() {
        DataField.initialize();
        arrows = new Rez.Drawables.arrows();
    }

    function onLayout(dc) {
        var obscurityFlags = DataField.getObscurityFlags();

        // TODO: Quadrant layouts are currently not properly supported
        // Top left quadrant so we'll use the top left layout
        if (obscurityFlags == (OBSCURE_TOP | OBSCURE_LEFT)) {
            View.setLayout(Rez.Layouts.TopLeftLayout(dc));

        // Top right quadrant so we'll use the top right layout
        } else if (obscurityFlags == (OBSCURE_TOP | OBSCURE_RIGHT)) {
            View.setLayout(Rez.Layouts.TopRightLayout(dc));

        // Bottom left quadrant so we'll use the bottom left layout
        } else if (obscurityFlags == (OBSCURE_BOTTOM | OBSCURE_LEFT)) {
            View.setLayout(Rez.Layouts.BottomLeftLayout(dc));

        // Bottom right quadrant so we'll use the bottom right layout
        } else if (obscurityFlags == (OBSCURE_BOTTOM | OBSCURE_RIGHT)) {
            View.setLayout(Rez.Layouts.BottomRightLayout(dc));

        // Use the generic, centered layout
        } else {
            View.setLayout(Rez.Layouts.MainLayout(dc));

            var labelView = View.findDrawableById("label");
            var valueView = View.findDrawableById("value");
            var unitsView = View.findDrawableById("units");
            var hoursView = View.findDrawableById("hours");

            labelView.setText(Rez.Strings.label);
            var heightAvailable = dc.getHeight() - dc.getFontHeight(Graphics.FONT_TINY) - MAX_PADDING;
            var fontValue;

            if (heightAvailable > dc.getFontHeight(Graphics.FONT_NUMBER_THAI_HOT)) {
                fontValue = Graphics.FONT_NUMBER_THAI_HOT;
                fontUnits = Graphics.FONT_MEDIUM;
            } else if (heightAvailable > dc.getFontHeight(Graphics.FONT_NUMBER_HOT)) {
                fontValue = Graphics.FONT_NUMBER_HOT;
                fontUnits = Graphics.FONT_SMALL;
            } else if (heightAvailable > dc.getFontHeight(Graphics.FONT_NUMBER_MEDIUM)) {
                fontValue = Graphics.FONT_NUMBER_MEDIUM;
                fontUnits = Graphics.FONT_TINY;
            } else {
                fontValue = Graphics.FONT_NUMBER_MILD;
                fontUnits = Graphics.FONT_XTINY;
            }

            var paddingValue = fontValue < Graphics.FONT_NUMBER_HOT ? 17 : 5;
            labelView.locY = labelView.locY + 6;
            valueView.locY = valueView.locY + paddingValue;
            valueView.setFont(fontValue);
        }
        return true;
    }

    function compute(info) {
        var distanceUnits = System.getDeviceSettings().distanceUnits;
        var adjustment = distanceUnits == System.UNIT_STATUTE ? 3.6f* STATUTE_UNIT_FACTOR : 3.6f;
        
        if(info has :currentSpeed and info.currentSpeed != null) {
            var speed = info.currentSpeed;
            value = (speed * adjustment).format("%.1f");
            
            if(info has :averageSpeed and info.averageSpeed != null) {
                faster = speed > info.averageSpeed;
            }
        } else {
            value = "__._";
            faster = null;
        }
    }

    function onUpdate(dc) {
        if(dc has :setAntiAlias) {
            dc.setAntiAlias(true);
        }
        // Set the background color
        View.findDrawableById("Background").setColor(getBackgroundColor());

        // Set the foreground color and value
        var valueView = View.findDrawableById("value");
        var labelView = View.findDrawableById("label");
        
        if (getBackgroundColor() == Graphics.COLOR_BLACK) {
            valueView.setColor(Graphics.COLOR_WHITE);
            labelView.setColor(Graphics.COLOR_WHITE);
        } else {
            valueView.setColor(Graphics.COLOR_BLACK);
            labelView.setColor(Graphics.COLOR_BLACK);
        }

        valueView.setText(value);

        // Call parent's onUpdate(dc) to redraw the layout
        View.onUpdate(dc);

        // Calculate positioning for arrows
        var offsetY = valueView.height * 0.1;
        var centerY = valueView.locY + valueView.height * 0.4;
        var height = valueView.height * 0.35;

        var centerX = valueView.locX - valueView.width*0.6 - 5;
        var width = valueView.width * 0.12;
        var start = centerX - width;
        var end = centerX + width;

        // Calculate positioning for units
        var paddingUnits = fontUnits < Graphics.FONT_SMALL ? 3 : 5;
        var centerXUnits = valueView.locX + valueView.width*0.5+paddingUnits;
        var distanceUnits = System.getDeviceSettings().distanceUnits;
        var units = distanceUnits == System.UNIT_STATUTE ? "m" : "km";
        
        // Draw units
        dc.drawText(centerXUnits, centerY - dc.getFontHeight(fontUnits), fontUnits, units, Graphics.TEXT_JUSTIFY_LEFT);
        dc.drawText(centerXUnits, centerY, fontUnits, "h", Graphics.TEXT_JUSTIFY_LEFT);

        // Draw arrows
        if (faster != null) {
            if (faster) { // Arrow up
                dc.fillPolygon(
                        [
                            [start, centerY - offsetY],
                            [centerX, centerY - height],
                            [end, centerY - offsetY]
                        ]
                    );
            } else { // Arrow down
                dc.fillPolygon(
                        [
                            [start, centerY + offsetY],
                            [centerX, centerY + height],
                            [end, centerY + offsetY]
                        ]
                    );
            }
            arrows.draw(dc);
        }
    }
}
