// Define manualmente la URL de la API
const apiUrl = ' ';

// Define la función callAPI que recibe un nombre y apellidos como parámetros
function callAPI(firstName, lastName) {
    // inicia un objeto header
    var myHeaders = new Headers();
    // añade contenido de header al objeto
    myHeaders.append("Content-Type", "application/json");
    // utiliza el objeto JSON y lo transforma en un string
    var raw = JSON.stringify({ "firstName": firstName, "lastName": lastName });
    // crea un objeto JSON con parametros para llamar a la API y guardarlo en una variable
    var requestOptions = {
        method: 'POST',
        headers: myHeaders,
        body: raw,
        redirect: 'follow'
    };
    // hace una llamada a la API y usa promesas para obtener la respuesta
    fetch(apiUrl, requestOptions)
        .then(response => response.text())
        .then(result => alert(JSON.parse(result).body))
        .catch(error => console.log('error', error));
}