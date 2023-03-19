var list = [];
$('[data-hotelid]').each(function (e) {
 list.push($(this).data('hotelid'));
});

var timeoutId;
window.addEventListener('scroll', function () {
 clearTimeout(timeoutId);
 timeoutId = setTimeout(function () {
  //setTimeout(function () {
  $('[data-hotelid]').each(function (e) {
   var hotelid = $(this).data('hotelid');
   if (!list.includes(hotelid)) {
    list.push(hotelid);
   }
  });
 }, 2000);
});
