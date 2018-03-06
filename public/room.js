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

        }
      })
  }
  setTimeout(loadMembers, 1000)

})
