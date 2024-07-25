const input =document.querySelector(".In1")
const select =document.querySelector("select")
const botao =document.querySelector(".BTNadvList")



function trocavolor(event){
    console.log(event)
}
//select.addEventListener("change",trocavolor)

//input.addEventListener("keypress",trocavolor)


botao.addEventListener("click", () => {
    alert("Botão clicado!")
})
