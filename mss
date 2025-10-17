//@version=5
indicator("MSS Detector", overlay=true, max_lines_count=500)

// ============================================================================
// USTAWIENIA MSS
// ============================================================================
group_mss = "Market Structure Shift Settings"
mss_length = input.int(8, "MSS Detection Length", minval=1, group=group_mss)
mss_bull_color = input.color(color.new(color.teal, 0), "Bullish MSS", group=group_mss)
mss_bear_color = input.color(color.new(color.red, 0), "Bearish MSS", group=group_mss)

// ============================================================================
// ZMIENNE MSS
// ============================================================================
var float pivot_high = na
var int pivot_high_bar = na
var bool pivot_high_crossed = false

var float pivot_low = na
var int pivot_low_bar = na
var bool pivot_low_crossed = false

var int mss_direction = 0  // 1 = bullish, -1 = bearish

// ============================================================================
// WYKRYWANIE MSS
// ============================================================================
ph = ta.pivothigh(mss_length, mss_length)
pl = ta.pivotlow(mss_length, mss_length)

if not na(ph)
    pivot_high := ph
    pivot_high_bar := bar_index - mss_length
    pivot_high_crossed := false

if not na(pl)
    pivot_low := pl
    pivot_low_bar := bar_index - mss_length
    pivot_low_crossed := false

// Bullish MSS - przebicie pivot high
if close > pivot_high and not pivot_high_crossed
    pivot_high_crossed := true
    if mss_direction == -1
        line.new(pivot_high_bar, pivot_high, bar_index, pivot_high,
                 color=mss_bull_color, width=2)
        label.new(bar_index, pivot_high, "BUY", 
                  yloc=yloc.abovebar,
                  y=10,
                  style=label.style_label_down, 
                  color=mss_bull_color, 
                  textcolor=color.white, 
                  size=size.small)
    mss_direction := 1

// Bearish MSS - przebicie pivot low
if close < pivot_low and not pivot_low_crossed
    pivot_low_crossed := true
    if mss_direction == 1
        line.new(pivot_low_bar, pivot_low, bar_index, pivot_low,
                 color=mss_bear_color, width=2)
        label.new(bar_index, pivot_low, "SELL",
                  style=label.style_label_up, 
                  color=mss_bear_color, 
                  textcolor=color.white, 
                  size=size.small)
    mss_direction := -1
