package controller;

import ufront.web.mvc.Controller;
import ufront.web.mvc.ViewResult;

class HomeController extends Controller {
    public function index() {
        return new ViewResult();
    }
}