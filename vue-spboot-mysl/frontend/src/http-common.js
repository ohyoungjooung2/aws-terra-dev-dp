import axios from "axios";

export default axios.create({
	//Should be public ip cause localhost always menas local pc ip(developers' usually)
//baseURL: "http://13.125.94.203:8080/api",
baseURL: "http://3.35.54.174:8080/api",
  headers: {
    "Content-type": "application/json",
  }
});