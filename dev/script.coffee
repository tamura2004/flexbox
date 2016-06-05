$ ->
  $(".box").click ->
    $(@)
    .animate
      top: "-10px"
    , 200
    .animate
      top: "0px"
    , 200
    .animate
      top: "-5px"
    , 100
    .animate
      top: "0px"
    , 100
    .animate
      top: "-2px"
    , 50
    .animate
      top: "0px"
    , 50

