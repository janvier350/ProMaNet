<%-- 
    Document   : index
    Created on : 14-feb-2017, 19:46:55
    Author     : Cpincay
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1.0, maximun-scale=1.0, minimun-scale=1.0">
        <title>ProMaNet | Inicia Sesion </title>
        <link rel="shorcut icon" href="image/logo.png">
              <link rel="stylesheet" href="css/bootstrap.min.css"> 
           
       
       <link href="Content/bootstrap/css/bootstrap.css" rel="stylesheet" type="text/css"/>
        <link href="Content/bootstrap/carousel/carousel.css" rel="stylesheet" type="text/css"/> 
        <link href="Content/Style.css" rel="stylesheet" type="text/css"/>
        <link rel="stylesheet" href="Content/font-awesome/css/font-awesome.min.css">
        <script src="Content/bootstrap/jquery.min.js" type="text/javascript"></script>
        <script src="Content/bootstrap/js/bootstrap.min.js" type="text/javascript"></script>
         
        
        <link href="//maxcdn.bootstrapcdn.com/bootstrap/4.1.1/css/bootstrap.min.css" rel="stylesheet" id="bootstrap-css">
<script src="//maxcdn.bootstrapcdn.com/bootstrap/4.1.1/js/bootstrap.min.js"></script>
<script src="//cdnjs.cloudflare.com/ajax/libs/jquery/3.2.1/jquery.min.js"></script>
              
    </head>
    
    <style>
      body {
    background:#333;
}
#login {
	-webkit-perspective: 1000px;
	-moz-perspective: 1000px;
	perspective: 1000px;
	margin-top:50px;
	margin-left:30%;
}
.login {
	font-family: 'Josefin Sans', sans-serif;
	-webkit-transition: .3s;
	-moz-transition: .3s;
	transition: .3s;
	-webkit-transform: rotateY(40deg);
	-moz-transform: rotateY(40deg);
	transform: rotateY(40deg);
}
.login:hover {
	-webkit-transform: rotate(0);
	-moz-transform: rotate(0);
	transform: rotate(0);
}
.login article {
	
}
.login .form-group {
	margin-bottom:17px;
}
.login .form-control,
.login .btn {
	border-radius:0;
}
.login .btn {
	text-transform:uppercase;
	letter-spacing:3px;
}
.input-group-addon {
	border-radius:0;
	color:#fff;
	background:#f3aa0c;
	border:#f3aa0c;
}
.forgot {
	font-size:16px;
}
.forgot a {
	color:#333;
}
.forgot a:hover {
	color:#5cb85c;
}

#inner-wrapper, #contact-us .contact-form, #contact-us .our-address {
    color: #1d1d1d;
    font-size: 19px;
    line-height: 1.7em;
    font-weight: 300;
    padding: 50px;
    background: #fff;
    box-shadow: 0 2px 5px 0 rgba(0, 0, 0, 0.16), 0 2px 10px 0 rgba(0, 0, 0, 0.12);
    margin-bottom: 100px;
}
.input-group-addon {
    border-radius: 0;
        border-top-right-radius: 0px;
        border-bottom-right-radius: 0px;
    color: #fff;
    background: #f3aa0c;
    border: #f3aa0c;
        border-right-color: rgb(243, 170, 12);
        border-right-style: none;
        border-right-width: medium;
}
    </style>
    <body style="background: url(image/fondo7.jpg) no-repeat center center fixed;
-webkit-background-size: cover;
-moz-background-size: cover;
-o-background-size: cover;
background-size: cover ">
       <br><br><br><br>
        
<!--        <div  class="container"  >
            
              <div class="row container" >
                  
                     <div  class="col-md-offset-4 col-md-4" align="center">
                         
                         <div style="color: #333333;
   background-color: rgba(211,211,211,0.4);" class="panel"  >
                        
                       <%--<script>fid="26"; width=auto; height=auto;</script><script type="text/javascript" src="http://www.tarjetaroja-tv.net/js/embedt.js"></script>--%>
                       <div class="panel-heading ">
                            <img src="image/buadnetLogin.png"   class="img-responsive ">
                           <h2><b>Iniciar Sesión</b></h2>
                          
                           
                       </div> 
                       <div class="panel-body">
                         <form  action="Ingreso" method="post" >
                          
                             <div class="form-group" >
                                <label for="usu">Usuario</label>
                           
                                <input type="text" name="usu" class="form-control" placeholder="Usuario" style="width:80%" required>
                            </div>
                            <div class="form-group">
                                <label for="passw">Contraseña</label>
                                <input type="password" name="pass"  class="form-control" placeholder="Contraseña" style="width:80%"  required >
                                
                            </div>  
                            
                            <div class="form-group">
                            
                                <div class="checkbox" >
                                    <label>
                                    <input type="checkbox" > No cerrar sesión
                                    </label>
                                </div>
                             
                            </div>
                            <div class="form-group">
                              
                                <button type="submit"  class="btn btn-success  " style="width:80%" ><span class="glyphicon glyphicon-user"  ></span> <b>Entrar</b></button>
                                 
                               
                            </div>
             
                        </form>  
                       </div>
                          
                    </div>
                    
                 
                </div> 
                  </div>
             </div>  -->
            
             <div class="col-md-4 col-md-offset-4" id="login">
               
                  <section id="inner-wrapper" class="login">
                      <div class="panel-heading ">
                          <img src="image/buadnetLogin.png"   class="img-responsive ">
                      </div>
                    <form  action="Ingreso" method="post" >

                                <div class="form-group" >
                                   <label for="usu">Usuario</label>

                                   <input type="text" name="usu" class="form-control" placeholder="Usuario" style="width:80%" required>
                               </div>
                               <div class="form-group">
                                   <label for="passw">Contraseña</label>
                                   <input type="password" name="pass"  class="form-control" placeholder="Contraseña" style="width:80%"  required >

                               </div>  
                               <div class="form-group">
                                   <div class="checkbox" >
                                       <label>
                                       <input type="checkbox" > No cerrar sesión
                                       </label>
                                   </div>
                               </div>
                               <div class="form-group">
                                   <button type="submit"  class="btn btn-success  " style="width:80%" ><span class="glyphicon glyphicon-user"  ></span> <b>Entrar</b></button>
                               </div>

                      </form>  
                  </section>
             
             </div>
        
               
                <script src="js/jquery.js"></script>
                <script src="js/bootstrap.min.js"></script>                    
                    
    </body>
</html>
