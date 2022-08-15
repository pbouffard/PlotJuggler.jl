xml_templates = (;
header = nsplitters -> """
<?xml version='1.0' encoding='UTF-8'?>
<root>
 <tabbed_widget parent="main_window" name="Main Window">
  <Tab containers="1" tab_name="tab1">
   <Container>
   <DockSplitter count="1" sizes="1" orientation="-">
   <DockSplitter count="$(nsplitters)" sizes="0.5;0.5" orientation="|">
  """,
   
dockarea = plotmode -> """
   <DockArea name="...">
    <plot mode="$(plotmode)" style="Lines">

""",

plot_foot = """
</plot>
""", 

dockarea_foot = """
</DockArea>
""",

xycurve = (xname, yname, color) -> """
<curve curve_y="$(yname)" color="$(color)" curve_x="$(xname)" name="$(xname) vs $(yname)"/>
""",

curve = (name, color) -> """
<curve 
name="$(name)"
color="$(color)"
/>
""",

footer = """
</DockSplitter>
</DockSplitter>
</Container>
</Tab>
<currentTabIndex index="0"/>
</tabbed_widget>
<use_relative_time_offset enabled="1"/>
<!-- - - - - - - - - - - - - - - -->
<!-- - - - - - - - - - - - - - - -->
<Plugins>
<plugin ID="DataLoad CSV">
  <default time_axis="t" delimiter="0"/>
</plugin>
<plugin ID="DataLoad ULog"/>
<plugin ID="UDP Server"/>
<plugin ID="WebSocket Server"/>
<plugin ID="ZMQ Subscriber"/>
<plugin ID="Fast Fourier Transform"/>
<plugin ID="Quaternion to RPY"/>
<plugin ID="Reactive Script Editor">
<library code="--[[ Helper function to create a series from arrays&#xa;&#xa; new_series: a series previously created with ScatterXY.new(name)&#xa; prefix:     prefix of the timeseries, before the index of the array&#xa; suffix_X:   suffix to complete the name of the series containing the X value. If [nil], use the index of the array.&#xa; suffix_Y:   suffix to complete the name of the series containing the Y value&#xa; timestamp:   usually the tracker_time variable&#xa;              &#xa; Example:&#xa; &#xa; Assuming we have multiple series in the form:&#xa; &#xa;   /trajectory/node.{X}/position/x&#xa;   /trajectory/node.{X}/position/y&#xa;   &#xa; where {N} is the index of the array (integer). We can create a reactive series from the array with:&#xa; &#xa;   new_series = ScatterXY.new(&quot;my_trajectory&quot;) &#xa;   CreateSeriesFromArray( new_series, &quot;/trajectory/node&quot;, &quot;position/x&quot;, &quot;position/y&quot;, tracker_time );&#xa;--]]&#xa;&#xa;function CreateSeriesFromArray( new_series, prefix, suffix_X, suffix_Y, timestamp )&#xa;  &#xa;  --- clear previous values&#xa;  new_series:clear()&#xa;  &#xa;  --- Append points to new_series&#xa;  index = 0&#xa;  while(true) do&#xa;&#xa;    x = index;&#xa;    -- if not nil, get the X coordinate from a series&#xa;    if suffix_X ~= nil then &#xa;      series_x = TimeseriesView.find( string.format( &quot;%s.%d/%s&quot;, prefix, index, suffix_X) )&#xa;      if series_x == nil then break end&#xa;      x = series_x:atTime(timestamp)&#x9; &#xa;    end&#xa;    &#xa;    series_y = TimeseriesView.find( string.format( &quot;%s.%d/%s&quot;, prefix, index, suffix_Y) )&#xa;    if series_y == nil then break end &#xa;    y = series_y:atTime(timestamp)&#xa;    &#xa;    new_series:push_back(x,y)&#xa;    index = index+1&#xa;  end&#xa;end&#xa;&#xa;--[[ Similar to the built-in function GetSeriesNames(), but select only the names with a give prefix. --]]&#xa;&#xa;function GetSeriesNamesByPrefix(prefix)&#xa;  -- GetSeriesNames(9 is a built-in function&#xa;  all_names = GetSeriesNames()&#xa;  filtered_names = {}&#xa;  for i, name in ipairs(all_names)  do&#xa;    -- check the prefix&#xa;    if name:find(prefix, 1, #prefix) then&#xa;      table.insert(filtered_names, name);&#xa;    end&#xa;  end&#xa;  return filtered_names&#xa;end&#xa;&#xa;--[[ Modify an existing series, applying offsets to all their X and Y values&#xa;&#xa; series: an existing timeseries, obtained with TimeseriesView.find(name)&#xa; delta_x: offset to apply to each x value&#xa; delta_y: offset to apply to each y value &#xa;  &#xa;--]]&#xa;&#xa;function ApplyOffsetInPlace(series, delta_x, delta_y)&#xa;  -- use C++ indeces, not Lua indeces&#xa;  for index=0, series:size()-1 do&#xa;    x,y = series:at(index)&#xa;    series:set(index, x + delta_x, y + delta_y)&#xa;  end&#xa;end&#xa;"/>
<scripts/>
</plugin>
<plugin ID="CSV Exporter"/>
</Plugins>
<!-- - - - - - - - - - - - - - - -->
<!-- - - - - - - - - - - - - - - -->
<customMathEquations/>
<snippets/>
<!-- - - - - - - - - - - - - - - -->
</root>
"""
)