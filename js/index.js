/// <reference types="../@types/jquery" />

const row = document.querySelector(".row.mt-5");
const cont = document.querySelector(".main");

$(function () {
  $(".loadScreen").fadeOut(1500, function () {
    $("body").css("overflow", "auto");
  });
});

function opneNavBar() {
  $("i.btnNav").addClass("fa-x");
  $("i.btnNav").removeClass("fa-align-justify");
  for (let i = 0; i < 5; i++) {
    $("li")
      .eq(i)
      .animate({ top: 0 }, (i + 1) * 500);
  }
  $(".nav").animate({ left: 0 }, 500);
}

function closNavBar() {
  $("i.btnNav").addClass("fa-align-justify");
  $("i.btnNav").removeClass("fa-x");
  $("li").animate({ top: 300 }, 500);

  let ow = $(".close").outerWidth();
  $(".nav").animate({ left: -ow }, 500);
}

closNavBar();

$(".btnNav").on("click", function () {
  if ($("i.btnNav").hasClass("fa-align-justify")) {
    opneNavBar();
  } else {
    closNavBar();
  }
});

function displaymealfrist(arr) {
  let containr = ``;
  for (let i = 0; i < arr.length; i++) {
    containr += ` <div class="col-md-3 mb-4">
    <div onclick="getmeal('${arr[i].strMeal}')" class=" position-relative overflow-hidden pointer">
      <img src="${arr[i].strMealThumb}" class=" w-100 rounded-2" alt="">
      <div class="position-absolute h-100 bg-layer w-100 rounded-2  d-flex flex-column justify-content-center">
        <h4 class="ps-2 text-black  ">${arr[i].strMeal}</h4>
      </div>
    </div>
  </div>`;
  }
  row.innerHTML = containr;
}

async function homeApi(meal = "") {
  let response = await fetch(
    ` https://www.themealdb.com/api/json/v1/1/search.php?s=${meal}`
  );
  let alldata = await response.json();
  displaymealfrist(alldata.meals);
  row.classList.remove("d-none");
}

async function letter(meal = "") {
  let response = await fetch(
    `https://www.themealdb.com/api/json/v1/1/search.php?f=${meal}`
  );
  let alldata = await response.json();
  displaymealfrist(alldata.meals);
  row.classList.remove("d-none");
}

homeApi();

async function getmeal(meal) {
  let response = await fetch(
    `https://www.themealdb.com/api/json/v1/1/search.php?s=${meal}`
  );
  let data = await response.json();

  containr = `
 <div class="col-md-4 ">
    <img class="w-100 rounded-3" src=${data.meals[0].strMealThumb} alt="">
    <h2>${data.meals[0].strMeal}</h2>
  </div>
  <div class="col-md-8 pb-5">
    <h2>Instructions</h2>
    <p>${data.meals[0].strInstructions}</p>
    <h3><span class="fw-bolder">Area : </span>${data.meals[0].strArea}</h3>
    <h3><span class="fw-bolder">Category : </span>${
      data.meals[0].strCategory
    }</h3>
    <h3>Recipes :</h3>
    <ul class="list-unstyled d-flex flex-wrap">
      ${displayIngredients(data.meals[0])}
    </ul>
    <h3>Tags :</h3>
    <ul class="list-unstyled d-flex flex-wrap">
      ${displayTags(data.meals[0])}
    </ul>
    <a href="${data.meals[0].strSource}" class="btn btn-success">Source</a>
    <a href="${data.meals[0].strYoutube}" class="btn btn-danger">Youtube</a>
  </div>`;
  row.innerHTML = containr;
}

function displayIngredients(meal) {
  let ingredients = ``;
  for (let i = 1; i <= 20; i++) {
    if (meal[`strIngredient${i}`] != "" && meal[`strMeasure${i}`] != "") {
      ingredients += `<li class="alert alert-info m-2 p-1">${
        meal[`strMeasure${i}`]
      } ${meal[`strIngredient${i}`]}</li>`;
    }
  }
  return ingredients;
}

function displayTags(meal) {
  let tags = meal.strTags?.split(",");
  let displayTags = ``;
  if (tags) {
    for (let i = 0; i < tags.length; i++) {
      displayTags += `
      <li class="alert alert-danger m-2 p-1">${tags[i]}</li>`;
    }
  }
  return displayTags;
}

$("li")
  .eq(0)
  .on("click", function () {
    $("div.container .row.mt-5").addClass("d-none");
    $("#search").removeClass("d-none");
    closNavBar();
  });

async function Categories() {
  let response = await fetch(
    ` https://www.themealdb.com/api/json/v1/1/categories.php`
  );
  let alldata = await response.json();
  row.classList.remove("d-none");
  disCategories(alldata.categories);
}

function disCategories(arr) {
  let containr = ``;
  for (let i = 0; i < arr.length; i++) {
    containr += ` <div class="col-md-3 mb-4">
    <div onclick="getmealCategories('${
      arr[i].strCategory
    }')" class=" position-relative overflow-hidden pointer">
      <img src="${arr[i].strCategoryThumb}" class=" w-100 rounded-2" alt="">
      <div class="position-absolute h-100 bg-layer w-100 rounded-2  d-flex flex-column justify-content-center align-items-center">
        <h1 class="ps-2 text-black  ">${arr[i].strCategory}</h1>
        <p class="text-black text-center">${arr[i].strCategoryDescription
          .split(" ")
          .slice(0, 20)
          .join(" ")}</p>
      </div>
    </div>
  </div>`;
  }
  row.innerHTML = containr;
}

async function getmealCategories(meal = "") {
  let response = await fetch(
    `https://www.themealdb.com/api/json/v1/1/filter.php?i=${meal}`
  );
  let alldata = await response.json();
  displaymealfrist(alldata.meals);
  row.classList.remove("d-none");
}

$("li")
  .eq(1)
  .on("click", function () {
    closNavBar();
    Categories();
    $("#search").addClass("d-none");
  });

async function area() {
  let response = await fetch(
    `https://www.themealdb.com/api/json/v1/1/list.php?a=list`
  );
  let alldata = await response.json();
  row.classList.remove("d-none");
  disArea(alldata.meals);
}

function disArea(arr) {
  let containr = ``;
  for (let i = 0; i < arr.length; i++) {
    containr += ` <div class="col-md-3 mb-4">
    <div onclick="getmealarea('${arr[i].strArea}')" class=" text-center text-white pointer">
      <i class="fa-solid fa-house-laptop fa-4x"></i>
        <h3>${arr[i].strArea}</h3>
    </div>
  </div>`;
  }
  row.innerHTML = containr;
}
async function getmealarea(meal = "") {
  let response = await fetch(
    `https://www.themealdb.com/api/json/v1/1/filter.php?a=${meal}`
  );
  let alldata = await response.json();
  displaymealfrist(alldata.meals);
  row.classList.remove("d-none");
}

$("li")
  .eq(2)
  .on("click", function () {
    closNavBar();
    area();
    $("#search").addClass("d-none");
  });

async function ingredients() {
  let response = await fetch(
    `https://www.themealdb.com/api/json/v1/1/list.php?i=list`
  );
  let alldata = await response.json();
  row.classList.remove("d-none");
  disIngredients(alldata.meals);
}

function disIngredients(arr) {
  let containr = ``;
  for (let i = 0; i < 24; i++) {
    containr += ` <div class="col-md-3 mb-4">
      <div onclick="getmealIngredients('${
        arr[i].strIngredient
      }')" class=" text-center text-white pointer">
       <i class="fa-solid fa-drumstick-bite fa-4x"></i>
          <h4>${arr[i].strIngredient}</h4>
         <p class=" text-center">${arr[i].strDescription
           .split(" ")
           .slice(0, 20)
           .join(" ")}</p>
      </div>
    </div>`;
  }
  row.innerHTML = containr;
}
async function getmealIngredients(meal = "") {
  let response = await fetch(
    `https://www.themealdb.com/api/json/v1/1/filter.php?i=${meal}`
  );
  let alldata = await response.json();
  displaymealfrist(alldata.meals);
  row.classList.remove("d-none");
}

$("li")
  .eq(3)
  .on("click", function () {
    closNavBar();
    ingredients();
    $("#search").addClass("d-none");
  });

function Contact() {
  let containr = `<div class="row mt-5 text-white w-75 mx-auto">
            <div class="col-md-6">
                <input id="nameInput" onkeyup="inputsValidation()" type="text" class="form-control" placeholder="Enter Your Name">
                <div id="nameAlert" class="alert alert-danger w-100 mt-2 d-none">
                    Special characters and numbers not allowed
                </div>
            </div>
            <div class="col-md-6">
                <input id="emailInput" onkeyup="inputsValidation()" type="email" class="form-control " placeholder="Enter Your Email">
                <div id="emailAlert" class="alert alert-danger w-100 mt-2 d-none">
                    Email not valid *exemple@yyy.zzz
                </div>
            </div>
            <div class="col-md-6">
                <input id="phoneInput" onkeyup="inputsValidation()" type="text" class="form-control " placeholder="Enter Your Phone">
                <div id="phoneAlert" class="alert alert-danger w-100 mt-2 d-none">
                    Enter valid Phone Number
                </div>
            </div>
            <div class="col-md-6">
                <input id="ageInput" onkeyup="inputsValidation()" type="number" class="form-control " placeholder="Enter Your Age">
                <div id="ageAlert" class="alert alert-danger w-100 mt-2 d-none">
                    Enter valid age
                </div>
            </div>
            <div class="col-md-6">
                <input id="passwordInput" onkeyup="inputsValidation()" type="password" class="form-control " placeholder="Enter Your Password">
                <div id="passwordAlert" class="alert alert-danger w-100 mt-2 d-none">
                    Enter valid password *Minimum eight characters, at least one letter and one number:*
                </div>
            </div>
            <div class="col-md-6">
                <input id="repasswordInput" onkeyup="inputsValidation()" type="password" class="form-control " placeholder="Repassword">
                <div id="repasswordAlert" class="alert alert-danger w-100 mt-2 d-none">
                    Enter valid repassword 
                </div>
            </div>
        </div>
        <button id="submitBtn" disabled="" class="btn btn-outline-danger px-2 mt-3">Submit</button>`;

  row.classList.remove("d-none");
  cont.innerHTML = containr;

  let submitBtn = document.getElementById("submitBtn");
  submitBtn = document.getElementById("submitBtn");

  let nameInput = document.getElementById("nameInput");
  let emailInput = document.getElementById("emailInput");
  let ageInput = document.getElementById("ageInput");
  let phoneInput = document.getElementById("phoneInput");
  let passwordInput = document.getElementById("passwordInput");
  let repasswordInput = document.getElementById("repasswordInput");

  let nameAlert = document.getElementById("nameAlert");
  let emailAlert = document.getElementById("emailAlert");
  let ageAlert = document.getElementById("ageAlert");
  let phoneAlert = document.getElementById("phoneAlert");
  let passwordAlert = document.getElementById("passwordAlert");
  let repasswordAlert = document.getElementById("repasswordAlert");

  nameInput.oninput = function () {
    validation(this, nameAlert);
    checkAllValidations();
  };
  emailInput.oninput = function () {
    validation(this, emailAlert);
    checkAllValidations();
  };
  ageInput.oninput = function () {
    validation(this, ageAlert);
    checkAllValidations();
  };
  phoneInput.oninput = function () {
    validation(this, phoneAlert);
    checkAllValidations();
  };

  let checkPass = "";
  passwordInput.oninput = function () {
    checkPass = validation(this, passwordAlert);
    checkAllValidations();
  };
  
  repasswordInput.oninput = function () {
    if (checkPass == this.value) {
      repasswordAlert.classList.add("d-none");
      this.classList.add("is-valid");
    } else {
      repasswordAlert.classList.remove("d-none");
      this.classList.remove("is-valid");
    }
    checkAllValidations();
  };
}

function checkAllValidations() {
  if (
    nameAlert.classList.contains("d-none") &&
    emailAlert.classList.contains("d-none") &&
    ageAlert.classList.contains("d-none") &&
    phoneAlert.classList.contains("d-none") &&
    passwordAlert.classList.contains("d-none") &&
    repasswordAlert.classList.contains("d-none") &&
    nameInput.value &&
    emailInput.value &&
    ageInput.value &&
    phoneInput.value &&
    passwordInput.value &&
    repasswordInput.value
  ) {
    submitBtn.removeAttribute("disabled");
  } else {
    submitBtn.setAttribute("disabled", true);
  }
}
function validation(e, ea) {
  let regex = {
    nameInput: /^[a-zA-Z]+$/,
    emailInput:
      /^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/,
    ageInput: /^(0?[1-9]|[1-9][0-9]|[1][1-9][1-9]|200)$/,
    phoneInput: /^[\+]?[(]?[0-9]{3}[)]?[-\s\.]?[0-9]{3}[-\s\.]?[0-9]{4,6}$/,
    passwordInput: /^(?=.*\d)(?=.*[a-z])[0-9a-zA-Z]{8,}$/,
  };

  if (regex[e.id].test(e.value)) {
    ea.classList.add("d-none");
    e.classList.add("is-valid");
  } else {
    ea.classList.remove("d-none");
    e.classList.remove("is-valid");
  }
  return e.value;
}

$("li")
  .eq(4)
  .on("click", function () {
    closNavBar();
    Contact();
    $("#search").addClass("d-none");
  });
