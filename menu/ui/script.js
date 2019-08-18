$(document).ready(function(){
  // Mouse Controls
  var documentWidth = document.documentElement.clientWidth;
  var documentHeight = document.documentElement.clientHeight;
  var cursor = $('#cursorPointer');
  var cursorX = documentWidth / 2;
  var cursorY = documentHeight / 2;
  var idEnt = 0;

  function UpdateCursorPos() {
    $('#cursorPointer').css('left', cursorX);
    $('#cursorPointer').css('top', cursorY);
  }

  function triggerClick(x, y) {
    var element = $(document.elementFromPoint(x, y));
    element.focus().click();
    return true;
  }

  // Listen for NUI Events
  window.addEventListener('message', function(event){
    // Crosshair
    if(event.data.crosshair == true){
      $(".crosshair").addClass('fadeIn');
      // $("#cursorPointer").css("display","block");
    }
    if(event.data.crosshair == false){
      $(".crosshair").removeClass('fadeIn').removeClass('active');
      // $("#cursorPointer").css("display","none");
    }
    if(event.data.close == true) {
      $(".crosshair").removeClass('fadeIn').removeClass('active');
      $(".menu").removeClass('fadeIn');
      $(".crossFake").css("display", "none");

    }

    var audioPlayer = null;
    if (event.data.transactionType == "playSound") {

      if (audioPlayer != null) {
        audioPlayer.pause();
      }

      audioPlayer = new Audio("./sounds/" + event.data.transactionFile + ".ogg");
      audioPlayer.volume = event.data.transactionVolume;
      audioPlayer.play();

    }

    // Menu
    if(event.data.menu == 'vehicle'){
      $(".crosshair").addClass('active');
      $(".menu-car").addClass('fadeIn');
      $(".crossFake").css("display", "block");
      if(event.data.praca == 'police' || event.data.praca == 'mechanic' ) {
        $("#odholuj").css("display", "block");
        $("#odblokuj").css("display", "block");
        $("#informacje").css("display", "block");
      }
      if(event.data.praca == 'mechanic') {
        $("#napraw").css("display", "block");
        $("#wyczysc").css("display", "block");
        $("#faktura").css("display", "block");
      }
      idEnt = event.data.idEntity;
      // $("#cursorPointer").css("display","none");
    }
    if(event.data.menu == 'user'){
      $(".crosshair").addClass('active');
      $(".menu-user").addClass('fadeIn');
      $(".crossFake").css("display", "block");
      idEnt = event.data.idEntity;
      if(event.data.kajdanki > 0){
        $("#kajdanki").css("opacity", "1");
      }
      if(event.data.praca == 'police') {
        $("#dowod").css("display", "block");
        $("#mandat").css("display", "block");
        $("#rachunki").css("display", "block");
      }
      // $("#cursorPointer").css("display","none");
    }
    if((event.data.menu == false)){
      $(".crosshair").removeClass('active');
      $(".menu").removeClass('fadeIn');
      $(".crossFake").css("display", "none");
      idEnt = 0;
    }

    // Click
    if (event.data.type == "click") {
      triggerClick(cursorX - 1, cursorY - 1);
    }
  });

  // Mousemove
  $(document).mousemove(function(event) {
    cursorX = event.pageX;
    cursorY = event.pageY;
    UpdateCursorPos();
  });

  // Click Menu

  // Functions
  // Vehicle
  $('.odholuj').on('click', function(e){
    e.preventDefault();
    $.post('http://menu/odholuj', JSON.stringify({
      id: idEnt
    }));
    $(".crosshair").removeClass('fadeIn').removeClass('active');
    $(".menu").removeClass('fadeIn');
    $(".crossFake").css("display", "none");
  });

  $('.odblokuj').on('click', function(e){
    e.preventDefault();
    $.post('http://menu/odblokuj', JSON.stringify({
      id: idEnt
    }));
    $(".crosshair").removeClass('fadeIn').removeClass('active');
    $(".menu").removeClass('fadeIn');
    $(".crossFake").css("display", "none");
  });

  $('.informacje').on('click', function(e){
    e.preventDefault();
    $.post('http://menu/informacje', JSON.stringify({
      id: idEnt
    }));
    $(".crosshair").removeClass('fadeIn').removeClass('active');
    $(".menu").removeClass('fadeIn');
    $(".crossFake").css("display", "none");
  });

  $('.napraw').on('click', function(e){
    e.preventDefault();
    $.post('http://menu/napraw', JSON.stringify({
      id: idEnt
    }));
    $(".crosshair").removeClass('fadeIn').removeClass('active');
    $(".menu").removeClass('fadeIn');
    $(".crossFake").css("display", "none");
  });

  $('.wyczysc').on('click', function(e){
    e.preventDefault();
    $.post('http://menu/wyczysc', JSON.stringify({
      id: idEnt
    }));
    $(".crosshair").removeClass('fadeIn').removeClass('active');
    $(".menu").removeClass('fadeIn');
    $(".crossFake").css("display", "none");
  });

  $('.faktura').on('click', function(e){
    e.preventDefault();
    $.post('http://menu/faktura', JSON.stringify({
      id: idEnt
    }));
    $(".crosshair").removeClass('fadeIn').removeClass('active');
    $(".menu").removeClass('fadeIn');
    $(".crossFake").css("display", "none");
  });

  $('.dowod').on('click', function(e){
    e.preventDefault();
    $.post('http://menu/dowod', JSON.stringify({
      id: idEnt
    }));
    $(".crosshair").removeClass('fadeIn').removeClass('active');
    $(".menu").removeClass('fadeIn');
    $(".crossFake").css("display", "none");
  });

  $('.mandat').on('click', function(e){
    e.preventDefault();
    $.post('http://menu/mandat', JSON.stringify({
      id: idEnt
    }));
    $(".crosshair").removeClass('fadeIn').removeClass('active');
    $(".menu").removeClass('fadeIn');
    $(".crossFake").css("display", "none");
  });

  $('.rachunki').on('click', function(e){
    e.preventDefault();
    $.post('http://menu/rachunki', JSON.stringify({
      id: idEnt
    }));
    $(".crosshair").removeClass('fadeIn').removeClass('active');
    $(".menu").removeClass('fadeIn');
    $(".crossFake").css("display", "none");
  });

  $('.kajdanki').on('click', function(e){
    e.preventDefault();
    $(".menu-user").removeClass('fadeIn');
    $(".menu-kajdanki").addClass('fadeIn');
    $(".crossFake").css("display", "block");
  });

  $('.zakuj').on('click', function(e){
    e.preventDefault();
    $.post('http://menu/zakuj', JSON.stringify({
      id: idEnt
    }));
  });

  $('.przemiesc').on('click', function(e){
    e.preventDefault();
    $.post('http://menu/przemiesc', JSON.stringify({
      id: idEnt
    }));
    $(".crosshair").removeClass('fadeIn').removeClass('active');
    $(".menu").removeClass('fadeIn');
    $(".crossFake").css("display", "none");
  });

  $('.przeszukaj').on('click', function(e){
    e.preventDefault();
    $.post('http://menu/przeszukaj', JSON.stringify({
      id: idEnt
    }));
    $(".crosshair").removeClass('fadeIn').removeClass('active');
    $(".menu").removeClass('fadeIn');
    $(".crossFake").css("display", "none");
  });

  $('.wloz').on('click', function(e){
    e.preventDefault();
    $.post('http://menu/wloz', JSON.stringify({
      id: idEnt
    }));
    $(".crosshair").removeClass('fadeIn').removeClass('active');
    $(".menu").removeClass('fadeIn');
    $(".crossFake").css("display", "none");
  });

  $('.wyciagnij').on('click', function(e){
    e.preventDefault();
    $.post('http://menu/wyciagnij', JSON.stringify({
      id: idEnt
    }));
    $(".crosshair").removeClass('fadeIn').removeClass('active');
    $(".menu").removeClass('fadeIn');
    $(".crossFake").css("display", "none");
  });



  $('.openCoffre').on('click', function(e){
    e.preventDefault();
    $.post('http://menu/togglecoffre', JSON.stringify({
      id: idEnt
    }));
    $(this).find('.text').text($(this).find('.text').text() == 'Ouvrir le coffre' ? 'Fermer le coffre' : 'Ouvrir le coffre');
  });

  $('.openCapot').on('click', function(e){
    e.preventDefault();
    $.post('http://menu/togglecapot', JSON.stringify({
      id: idEnt
    }));
    $(this).find('.text').text($(this).find('.text').text() == 'Ouvrir le capot' ? 'Fermer le capot' : 'Ouvrir le capot');
  });

  $('.lock').on('click', function(e){
    e.preventDefault();
    $.post('http://menu/togglelock', JSON.stringify({
      id: idEnt
    }));
    $(this).find('.text').text($(this).find('.text').text() == 'Zamknięty' ? 'Otwarty' : 'Zamknięty');
  });

  // Functions
  // User
  $('.cheer').on('click', function(e){
    e.preventDefault();
    $.post('http://menu/cheer', JSON.stringify({
      id: idEnt
    }));
  });


  // Click Crosshair
  $('.crosshair').on('click', function(e){
    e.preventDefault();
    $(".crosshair").removeClass('fadeIn').removeClass('active');
    $(".menu").removeClass('fadeIn');
    $(".crossFake").css("display", "none");
    $.post('http://menu/disablenuifocus', JSON.stringify({
      nuifocus: false
    }));
  });
  $(document).keypress(function(e){
    if(e.which == 101){ // if "E" is pressed
      $(".crosshair").removeClass('fadeIn').removeClass('active');
      $(".menu").removeClass('fadeIn');
      $(".crossFake").css("display", "none");
      $.post('http://menu/disablenuifocus', JSON.stringify({
        nuifocus: false
      }));
    }
  });

});
