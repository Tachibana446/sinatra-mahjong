$(() => {
  let loadChat = () => {
    $.ajax({
      url: '/chat/' + roomno,
      type: 'GET',
    }).done((data) => {
      let tbody = $('div.chat > .list > tbody')
      tbody.html('')
      for (d of $.parseJSON(data)) {
        tbody.append($(`<tr><td>${d['name']}</td><td>${d['message']}</td></tr>`))
      }
    })
  }
  loadChat()
  $('.chat .reload').on('click', () => loadChat())
  $('.chat .submit').on('click', () => {
    let message = $('.input_chat').val()
    if (message === '') return
    $('.input_chat').val('')
    $.ajax({
      url: '/chat/' + roomno,
      type: 'POST',
      data: {
        'name': username,
        'message': message,
      }
    }).done((data) => {
      let tbody = $('div.chat > .list > tbody')
      tbody.html('')
      for (d of $.parseJSON(data)) {
        tbody.append($(`<tr><td>${d['name']}</td><td>${d['message']}</td></tr>`))
      }
    })
  })
})
