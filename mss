//@version=5
indicator("MSS Detector", overlay=true, max_lines_count=500)

// ============================================================================
// USTAWIENIA MSS
// ============================================================================
group_mss = "Market Structure Shift Settings"
mss_bull_color = input.color(color.new(color.teal, 0), "Bullish MSS", group=group_mss)
mss_bear_color = input.color(color.new(color.red, 0), "Bearish MSS", group=group_mss)

// ============================================================================
// USTAWIENIA STRUKTURY
// ============================================================================
group_structure = "Structure Detection"
use_high_low_break = input.bool(true, "Use High/Low Breaks", inline="break", group=group_structure,
     tooltip="If enabled, structure shifts require the candle high/low to be broken. If disabled, the close must break the level.")
show_structure_levels = input.bool(false, "Show Active Structure Levels", inline="struct", group=group_structure)
structure_level_color = input.color(color.new(color.gray, 70), "", inline="struct", group=group_structure)

// ============================================================================
// ZMIENNE STRUKTURY
// ============================================================================
var float structure_high = na
var int structure_high_bar = na
var float structure_low = na
var int structure_low_bar = na
var int structure_direction = 0  // 1 = bullish, -1 = bearish
var line structure_high_line = na
var line structure_low_line = na

if barstate.isfirst
    structure_high := high
    structure_low := low
    structure_high_bar := bar_index
    structure_low_bar := bar_index

break_price_high = structure_high
break_price_low = structure_low
break_bar_high = structure_high_bar
break_bar_low = structure_low_bar

break_condition_bull = structure_direction <= 0 and not na(break_price_high) and (
     (use_high_low_break and high > break_price_high) or
     (not use_high_low_break and close > break_price_high))

break_condition_bear = structure_direction >= 0 and not na(break_price_low) and (
     (use_high_low_break and low < break_price_low) or
     (not use_high_low_break and close < break_price_low))

if break_condition_bull
    line.new(break_bar_high, break_price_high, bar_index, break_price_high,
             color=mss_bull_color, width=2)
    label.new(bar_index, break_price_high, "BUY",
              yloc=yloc.abovebar,
              style=label.style_label_down,
              color=mss_bull_color,
              textcolor=color.white,
              size=size.small)
    structure_direction := 1
    structure_high := high
    structure_high_bar := bar_index
    structure_low := low
    structure_low_bar := bar_index

if break_condition_bear
    line.new(break_bar_low, break_price_low, bar_index, break_price_low,
             color=mss_bear_color, width=2)
    label.new(bar_index, break_price_low, "SELL",
              yloc=yloc.belowbar,
              style=label.style_label_up,
              color=mss_bear_color,
              textcolor=color.white,
              size=size.small)
    structure_direction := -1
    structure_high := high
    structure_high_bar := bar_index
    structure_low := low
    structure_low_bar := bar_index

// ============================================================================
// AKTUALIZACJA STRUKTURY
// ============================================================================
if structure_direction == 1
    if low < structure_low or na(structure_low)
        structure_low := low
        structure_low_bar := bar_index
    if high > structure_high or na(structure_high)
        structure_high := high
        structure_high_bar := bar_index
else if structure_direction == -1
    if high > structure_high or na(structure_high)
        structure_high := high
        structure_high_bar := bar_index
    if low < structure_low or na(structure_low)
        structure_low := low
        structure_low_bar := bar_index
else
    if high > structure_high or na(structure_high)
        structure_high := high
        structure_high_bar := bar_index
    if low < structure_low or na(structure_low)
        structure_low := low
        structure_low_bar := bar_index

// ============================================================================
// LINIJE STRUKTURY
// ============================================================================
if show_structure_levels
    if structure_direction <= 0
        if na(structure_high_line)
            structure_high_line := line.new(structure_high_bar, structure_high, bar_index, structure_high,
                                            color=structure_level_color, width=1, extend=extend.right)
        else
            line.set_xy1(structure_high_line, structure_high_bar, structure_high)
            line.set_xy2(structure_high_line, bar_index, structure_high)
    else
        if not na(structure_high_line)
            line.delete(structure_high_line)
            structure_high_line := na
    if structure_direction >= 0
        if na(structure_low_line)
            structure_low_line := line.new(structure_low_bar, structure_low, bar_index, structure_low,
                                           color=structure_level_color, width=1, extend=extend.right)
        else
            line.set_xy1(structure_low_line, structure_low_bar, structure_low)
            line.set_xy2(structure_low_line, bar_index, structure_low)
    else
        if not na(structure_low_line)
            line.delete(structure_low_line)
            structure_low_line := na
else
    if not na(structure_high_line)
        line.delete(structure_high_line)
        structure_high_line := na
    if not na(structure_low_line)
        line.delete(structure_low_line)
        structure_low_line := na
