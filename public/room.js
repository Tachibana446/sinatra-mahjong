var myhand = []

$(() => {
  let isPlayersFour = false
  var members = []
  let loadMembers = () => {
    $.ajax({
        url: '/room_members/' + roomno,
        type: 'GET',
      })
      .done((data) => {
        members = $.parseJSON(data)
        $('#members').html('')
        for (m of members) {
          $('#members').append($(`<li>${m['name']}</li>`))
        }

        if (members.length < 4) {
          setTimeout(loadMembers, 3000)
        } else {
          play()
        }
      })
  }
  setTimeout(loadMembers, 1000)

})

function play() {
  $.ajax({
      url: `/room/${roomno}/my_info/${username}`,
      type: 'GET',
    })
    .done((data) => {
      data = $.parseJSON(data)
      $('.playarea .deck .count').text(data['room']['deck'])
      $('.wanpai .count').text(data['room']['wanpai'])
      $('.wanpai .dora').empty()
      $('.wanpai .dora').append($(`<div class="pai">${data['room']['dora_display']}</div>`))
      for (user of data['users']) {
        if (user['name'] == username) {
          $('.playarea .my_hand').empty()
          for (p of user['hand']) {
            $('.playarea .my_hand').append($(`<div class="pai">${p}</div>`))
          }
          // TODO Discard
        } else {
          let div = $('.playarea .other_players:eq(0)')
          if (user['position'] == 'forward')
            div = $('.playarea .other_players:eq(1)')
          else if (user['position'] == 'right')
            div = $('.playarea .other_players:eq(2)')

          div.find('.hand').empty()
          for(_i in user['hand_length'] ) {
            div.find('.hand').append($(`<div class="pai"></div>`))
          }
          // TODO discard
        }
      }
      setTimeout(play, 1000)
    })
}
