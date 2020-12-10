using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;

class SigmaSpeedView extends WatchUi.DataField {

    const STATUTE_UNIT_FACTOR = 0.621371f;

    hidden var speed = 0.0f;
    hidden var faster = false;
    hidden var adjustment = 3.6f;
    hidden var units = "km";

    var arrows;

    function initialize() {
        DataField.initialize();
        arrows = new Rez.Drawables.arrows();

        var distanceUnits = System.getDeviceSettings().distanceUnits;

        if (distanceUnits == System.UNIT_STATUTE) {
            adjustment *= STATUTE_UNIT_FACTOR;
            units = "m";
        }
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
                paddingValue = 5;
            } else if (heightAvailable > dc.getFontHeight(Graphics.FONT_NUMBER_HOT)) {
                fontValue = Graphics.FONT_NUMBER_HOT;
                paddingValue = 5;
            } else if (heightAvailable > dc.getFontHeight(Graphics.FONT_NUMBER_MEDIUM)) {
                fontValue = Graphics.FONT_NUMBER_MEDIUM;
                paddingValue = 17;
            } else {
                fontValue = Graphics.FONT_NUMBER_MILD;
                paddingValue = 17;
            }

            labelView.locY = labelView.locY + 5;
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
        // See Activity.Info in the documentation for available information.
        speed = 0.0f;
        if(info has :currentSpeed){
            if(info.currentSpeed != null){
                speed = info.currentSpeed;
            }
        }
        var avg = 0.0f;
        if(info has :averageSpeed){
            if(info.averageSpeed != null){
                avg = info.averageSpeed;
            }
        }
        faster = speed > avg;
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
        var value = View.findDrawableById("value");
        var label = View.findDrawableById("label");
        
        if (getBackgroundColor() == Graphics.COLOR_BLACK) {
            value.setColor(Graphics.COLOR_WHITE);
            label.setColor(Graphics.COLOR_WHITE);
        } else {
            value.setColor(Graphics.COLOR_BLACK);
            label.setColor(Graphics.COLOR_BLACK);
        }

        var speedAdjusted = speed * adjustment;
        value.setText(speedAdjusted.format("%.1f"));

        // Call parent's onUpdate(dc) to redraw the layout
        View.onUpdate(dc);

        var offsetY = value.height * 0.1;
        var centerY = value.locY + value.height * 0.4;
        var height = value.height * 0.3;

        var centerX = value.locX - value.width*0.65;
        var width = value.width * 0.1;
        var start = centerX - width;
        var end = centerX + width;

        var centerXUnits = value.locX + value.width*0.65;
        
        dc.drawText(centerXUnits, centerY - dc.getFontHeight(Graphics.FONT_TINY), Graphics.FONT_TINY, units, Graphics.TEXT_JUSTIFY_LEFT);
        dc.drawText(centerXUnits, centerY, Graphics.FONT_TINY, "h", Graphics.TEXT_JUSTIFY_LEFT);

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
