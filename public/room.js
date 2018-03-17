var me = {}
var prev_hand = []
var is_now_player = false

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

  // jQuery
  var dragPai = null
  $('.my_player .my_hand').on('dragstart', '.pai', e => {
    if (e.originalEvent)
      e = e.originalEvent
    e.target.style.opacity = '0.4'
    dragPai = $(e.target)
    e.dataTransfer.effectAllowed = 'move'
  })
  $('.my_player .my_hand').on('dragenter', '.pai', e => $(e.target).addClass('over'))
  $('.my_player .my_hand').on('dragleave', '.pai', e => $(e.target).removeClass('over'))
  $('.my_player .my_hand').on('dragover', '.pai', e => {
    if (e.originalEvent)
      e = e.originalEvent
    if (e.preventDefault)
      e.preventDefault();
    e.dataTransfer.dropEffect = 'move'
    return false
  })
  $('.my_player .my_hand').on('drop', '.pai', e => {
    if (e.originalEvent)
      e = e.originalEvent
    if (e.stopPropagation)
      e.stopPropagation()
    if (dragPai != e.target) {
      let temp = dragPai.html()
      target = $(e.target)
      dragPai.html(target.html())
      target.html(temp)
    }
    return false
  })
  $('.my_player .my_hand').on('dragend', '.pai', e => {
    e.target.style.opacity = '1.0'
    $('.my_player .my_hand .pai.over').each((i, elem) => $(elem).removeClass('over'))
  })

})

function diff(_arr1, _arr2) {
  let a1 = _arr1.slice()
  let a2 = _arr2.slice()

  for (v of a2) {
    let index = a1.indexOf(v)
    if (index >= 0)
      a1.splice(index, 1)
  }
  return a1
}

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
          me = user
          is_now_player = user['kaze'] == data['room']['now_player']
          // 手が前回と異なれば更新
          if (prev_hand.toString() != user['hand'].toString()) {
            prev_hand = user['hand']
            $('.playarea .my_hand').empty()
            for (p of user['hand']) {
              $('.playarea .my_hand').append($(`<div class="pai" draggable="true">${p}</div>`))
            }
            if (user['tsumo']) {
              $('.playarea .tsumo').empty()
              $('.playarea .tsumo').append($(`<div class="pai">${user['tsumo']}</div>`))
            }
          }
          // TODO Discard
        } else {
          let div = $('.playarea .other_player:eq(0)')
          if (user['position'] == 'forward')
            div = $('.playarea .other_player:eq(1)')
          else if (user['position'] == 'right')
            div = $('.playarea .other_player:eq(2)')

          div.find('.hand').empty()
          for (let i = 0; i < user['hand_length']; i++) {
            div.find('.hand').append($(`<div class="pai back"></div>`))
          }
          // TODO discard
        }
      }
      setTimeout(play, 1000)
    })
}
