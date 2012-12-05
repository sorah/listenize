jQuery ($) ->
  add_channel = (channel) ->
    template = $('#template .channel')[0].outerHTML
    rendered =  Mustache.render(template, channel)
    $('#channels').append rendered

  queue = {}
  playing = {}

  make_timbre = (payload) -> T.apply(this, payload.t).set({mul: parseInt($('#control .volume').val(), 10) / 100})

  play_loop = (channel) ->
    if 0 < queue[channel].length
      payload = queue[channel].shift()
      payload.timbre =  make_timbre(payload)
      payload.timbre.play()
      playing[channel] = payload
      if payload.time
        setTimeout ->
          payload.timbre.pause() if playing[channel]
          play_loop(channel)
        , payload.time
    else
      playing[channel] = null



  source = new EventSource('/api/stream')
  source.addEventListener 'payload', (e) ->
    payload = JSON.parse(e.data)
    console.log payload
    add_channel(name: payload.channel) unless $("#ch_#{payload.channel}")[0]

    if playing[payload.channel] && (payload.stop || !(playing[payload.channel].time))
      playing[payload.channel].timbre.pause()
      playing[payload.channel] = null

    if playing[payload.channel]
      queue[payload.channel].push(payload)
    else
      queue[payload.channel] = [payload]
      play_loop(payload.channel)

