
package Servlets;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
//import javax.servlet.http.HttpSession;
//import static Servlets.Sql.getFila;

/**
 * @author Janvier
 */
@WebServlet(name = "Ingreso", urlPatterns = {"/Ingreso"})
public class Ingreso extends HttpServlet {
    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code>
     * methods.
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();
       
        try {
            
            String usuario = request.getParameter("usu");
            String contra = request.getParameter("pass");
              
            String[] datos = Sql.getFila("select a.idusuario,a.contrasena, b.idcompania,b.compania, c.cargo, a.nombre, a.apellidos,D.CARGOTODO, a.email, a.telefono , e.departamento, a.id_adm_departamento, a.sueldo, a.IDROL "
                    + "from usuario a , COMPANIA b , rol c , TODOROL D, ADM_DEPARTAMENTO  E "
                    + "where a.USUARIO = '"+usuario+"' and a.CONTRASENA = '"+contra+"' and a.IDCOMPANIA = b.IDCOMPANIA and a.IDROL = c.IDROL AND A.IDROLTODO=D.IDROLTODO and a.ESTADO = 'a' AND a.id_adm_departamento = e.id_departamento");
           System.out.println("arreglo");
            if(datos == null){
              response.sendRedirect("break.jsp");
            }else {
                
                String id= datos[0];
                String usu = usuario;    
                String pass= datos[1];
                String idComania= datos[2];
                String compania= datos[3];
                String cargo = datos[4];
                String nombre = datos[5];
                String apellidos = datos[6];
                String roltodo = datos[7];
                 String email = datos[8];
                 String telefono = datos[9];
                 String departamento = datos[10];
                 String idDepartamento = datos[11];
                 String sueldo = datos[12];
                 String idRol = datos[13];
                // habilitamos la sesion
                HttpSession session = request.getSession(true);
                // mover a la pagina la consulta de el select
                session.setAttribute("cod",String.valueOf(id)); //id
                session.setAttribute("usuario",usuario); //usuario
                session.setAttribute("idCompa",String.valueOf(idComania)); //id empresa
                session.setAttribute("compania",compania); //id
                session.setAttribute("cargo",cargo); //id
                session.setAttribute("nombre",nombre); //id
                session.setAttribute("apellidos",apellidos); //id
                session.setAttribute("roltodo",roltodo); //id
                session.setAttribute("email",email); //id
                session.setAttribute("telefono",telefono); //id
                session.setAttribute("departamento",departamento); //id
                session.setAttribute("idDepartamento",idDepartamento); //id
                session.setAttribute("sueldo",String.valueOf(sueldo)); //sueldo
                session.setAttribute("ipDB","jdbc:oracle:thin:@181.198.203.205:1521:xe");
                session.setAttribute("userDB","RRHH");
                session.setAttribute("passDB","RRHH");
                session.setAttribute("permisos", COMUN.PermisoHelper.cargarPermisos(Integer.parseInt(id.trim()), Integer.parseInt(idRol.trim())));

                    
                if(cargo.equals("ADMINISTRACION") ||cargo.equals("ASISTENTE") ||cargo.equals("ADMINISTRADOR")||cargo.equals("ANALISTA")|| cargo.equals("JEFE") || cargo.equals("CONTRALOR") || cargo.equals("PASANTE")){
                    response.sendRedirect("Proyectos/PRO_Dashboard.jsp");
//                    response.sendRedirect("Home.jsp");
             System.out.println("ok");
          
                }else{
                    
                    session.invalidate();
                    response.sendRedirect("sesionInvalida.jsp");
                }
            }
            
        } finally {
            out.close();
        }
    }

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /**
     * Handles the HTTP <code>GET</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    /**
     * Handles the HTTP <code>POST</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
