

$.ajaxSetup beforeSend: (xhr) ->
 xhr.setRequestHeader 'X-CSRF-Token', $('meta[name="csrf-token"]').attr('content')

if window.location.hostname is "0.0.0.0" or window.location.hostname is "localhost"
  Spine.Model.host = "http://0.0.0.0:3000" 
else
  Spine.Model.host = "http://setiMarv.com"