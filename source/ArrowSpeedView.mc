using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;

class ArrowSpeedView extends WatchUi.DataField {

    const STATUTE_UNIT_FACTOR = 0.621371f;

    hidden var value = "__._";
    hidden var faster = null;
    hidden var fontUnits = Graphics.FONT_TINY;
    hidden var arrows;

    function initialize() {
        DataField.initialize();
        arrows = new Rez.Drawables.arrows();
    }

    // Set your layout here. Anytime the size of obscurity of
    // the draw context is changed this will be called.
    function onLayout(dc) {
        var obscurityFlags = DataField.getObscurityFlags();

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

            // unitsView.setText("km");
            // hoursView.setText("h");

            labelView.setText(Rez.Strings.label);
            var heightAvailable = dc.getHeight() - dc.getFontHeight(Graphics.FONT_TINY) - 10; // max padding -> 10
            var paddingValue, fontValue;

            if (heightAvailable > dc.getFontHeight(Graphics.FONT_NUMBER_THAI_HOT)) {
                fontValue = Graphics.FONT_NUMBER_THAI_HOT;
                fontUnits = Graphics.FONT_MEDIUM;
                paddingValue = 5;
            } else if (heightAvailable > dc.getFontHeight(Graphics.FONT_NUMBER_HOT)) {
                fontValue = Graphics.FONT_NUMBER_HOT;
                fontUnits = Graphics.FONT_SMALL;
                paddingValue = 5;
            } else if (heightAvailable > dc.getFontHeight(Graphics.FONT_NUMBER_MEDIUM)) {
                fontValue = Graphics.FONT_NUMBER_MEDIUM;
                fontUnits = Graphics.FONT_TINY;
                paddingValue = 17;
            } else {
                fontValue = Graphics.FONT_NUMBER_MILD;
                fontUnits = Graphics.FONT_XTINY;
                paddingValue = 17;
            }

            labelView.locY = labelView.locY + 6;
            valueView.locY = valueView.locY + paddingValue;
            valueView.setFont(fontValue);
        }
        return true;
    }

    // The given info object contains all the current workout information.
    // Calculate a value and save it locally in this method.
    // Note that compute() and onUpdate() are asynchronous, and there is no
    // guarantee that compute() will be called before onUpdate().
    function compute(info) {
        var distanceUnits = System.getDeviceSettings().distanceUnits;
        var adjustment = 3.6f;
        if (distanceUnits == System.UNIT_STATUTE) {
            adjustment *= 3.6f* STATUTE_UNIT_FACTOR;
        }
        // See Activity.Info in the documentation for available information.
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

    // Display the value you computed here. This will be called
    // once a second when the data field is visible.
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

        var offsetY = valueView.height * 0.1;
        var centerY = valueView.locY + valueView.height * 0.4;
        var height = valueView.height * 0.3;

        var centerX = valueView.locX - valueView.width*0.6 - 5;
        var width = valueView.width * 0.1;
        var start = centerX - width;
        var end = centerX + width;

        var centerXUnits = valueView.locX + valueView.width*0.5+paddingUnits;
        var distanceUnits = System.getDeviceSettings().distanceUnits;
        var paddingUnits = fontUnits < Graphics.FONT_SMALL ? 3 : 5;
        var units = "km";

        if (distanceUnits == System.UNIT_STATUTE) {
            units = "m";
        }
        
        dc.drawText(centerXUnits, centerY - dc.getFontHeight(fontUnits), fontUnits, units, Graphics.TEXT_JUSTIFY_LEFT);
        dc.drawText(centerXUnits, centerY, fontUnits, "h", Graphics.TEXT_JUSTIFY_LEFT);

        if (faster != null) {
            if (faster) {
                dc.fillPolygon(
                        [
                            [start, centerY - offsetY],
                            [centerX, centerY - height],
                            [end, centerY - offsetY]
                        ]
                    );
            } else {
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