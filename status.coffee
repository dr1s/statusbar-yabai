command: './scripts/status.py'

refreshFrequency: 10000 # ms

render: (output) ->
  """
    <div class="compstatus"></div>
  """

style: """
  right: 28px
  top: 2px
  height: 13
  .wifi
    font: 14px FontAwesome
    top: 1px
    position: relative
    left: 10px
  .charging
    font: 12px FontAwesome
    position: relative
    top: 0px
    right: -12px
    z-index: 1
  """
timeAndDate: (date, time) ->
  # returns a formatted html string with the date and time
  return "<span class='white'><span class='icon'>&nbsp&nbsp;</span>#{date}&nbsp<span> ⎢ </span><span class='icon'>&nbsp;</span>#{time}</span></span>";

batteryStatus: (battery, state) ->
  #returns a formatted html string current battery percentage, a representative icon and adds a lighting bolt if the
  # battery is plugged in and charging

  # If no battery exists, battery is only '%' character
  if state == 'AC' and battery == "%"
    return "<span class='green icon'></span>"

  batnum = parseInt(battery)
  if state == 'AC' and batnum >= 90
    return "<span class='charging yellow outline_icon sicon'></span><span class='green icon '></span>&nbsp;<span class='white'>#{batnum}%</span>"
  else if state == 'AC' and batnum >= 50 and batnum < 90
    return "<span class='charging yellow outline_icon icon'></span><span class='green icon'></span>&nbsp;<span class='white'>#{batnum}%</span>"
  else if state == 'AC' and batnum < 50 and batnum >= 15
    return "<span class='charging yellow outline_icon icon'></span><span class='yellow icon'></span>&nbsp;<span class='white'>#{batnum}%</span>"
  else if state == 'AC' and batnum < 15
    return "<span class='charging yellow icon'></span><span class='red icon'></span>&nbsp;<span class='white'>#{batnum}%</span>"
  else if batnum >= 90
    return "<span class='green icon'>&nbsp</span>&nbsp;<span class='white'>#{batnum}%</span>"
  else if batnum >= 50 and batnum < 90
    return "<span class='green icon'>&nbsp</span>&nbsp;<span class='white'>#{batnum}%</span>"
  else if batnum < 50 and batnum >= 25
    return "<span class='yellow icon'>&nbsp</span>&nbsp;<span class='white'>#{batnum}%</span>"
  else if batnum < 25 and batnum >= 15
    return "<span class='yellow icon'>&nbsp</span>&nbsp;<span class='white'>#{batnum}%</span>"
  else if batnum < 15
    return "<span class='red icon'>&nbsp</span>&nbsp;<span class='white'>#{batnum}%</span>"

getWifiStatus: (status, netName, netIP) ->
  if status == "Wi-Fi"
    return "<span class='wifi '>&nbsp&nbsp&nbsp&nbsp;</span><span class='white'>#{netName}&nbsp</span>"
  if status == 'USB 10/100/1000 LAN' or status == 'Apple USB Ethernet Adapter'
    return "<span class='wifi '>&nbsp&nbsp&nbsp&nbsp;</span><span class='white'>#{netIP}</span>"
  else
    return "<span class='grey wifi'>&nbsp&nbsp&nbsp</span><span class='white'>--&nbsp&nbsp&nbsp</span>"

getVolume: (str) ->
  if str == "0"
    return "<span class='volume'>&nbsp;&nbsp;</span>"
  else
    return "<span class='volume'>&nbsp;&nbsp;</span><span class='white'>#{str}&nbsp</span>"

getCurrentTime: () ->
  today = new Date
  hours = today.getHours()
  minutes = today.getMinutes()
  if minutes < 10
    minutes = '0' + minutes
  if hours < 10
    hours = '0' + hours
  time = hours + ':' + minutes
  return time

getCurrentDate: () ->
  today = new Date
  daylist = [
    'Sun'
    'Mon'
    'Tue'
    'Wed'
    'Thu'
    'Fri'
    'Sat'
  ]
  month_list = [
    'Jan'
    'Feb'
    'Mar'
    'Apr'
    'May'
    'Jun'
    'Jul'
    'Aug'
    'Sep'
    'Oct'
    'Nov'
    'Dec'
  ]
  day = daylist[today.getDay()]
  date = today.getDate()
  month = month_list[today.getMonth()]
  year = today.getYear() + 1900
  output=day + ', ' + month + ' ' + date + ' ' + year
  return output



update: (output, domEl) ->

  # split the output of the script
  values = output.split('@')

  time = @getCurrentTime()
  date = @getCurrentDate()
  battery = values[0]
  isCharging = values[1]
  netStatus = values[2].replace /^\s+|\s+$/g, ""
  netName = values[3]
  netIP = values[4]
  volume = values[5]

  # create an HTML string to be displayed by the widget
  htmlString = @getVolume(volume) + "<span>" + " ⎢" + "</span>" +
               @getWifiStatus(netStatus, netName, netIP) + "<span>" + " ⎢ " + "</span>" +
               @batteryStatus(battery, isCharging) + "<span>" + " ⎢ " + "</span>" +
               @timeAndDate(date,time)

  $(domEl).find('.compstatus').html(htmlString)
