package Servlets;

import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.File;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.ArrayList;
import java.util.List;
import org.apache.commons.fileupload.FileItem;
import org.apache.commons.fileupload.FileItemFactory;
import org.apache.commons.fileupload.disk.DiskFileItemFactory;
import org.apache.commons.fileupload.servlet.ServletFileUpload;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;

@WebServlet(name = "INV_EditarEquipo", urlPatterns = {"/INV_EditarEquipo"})
public class INV_EditarEquipo extends HttpServlet {
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        HttpSession session = request.getSession(true);

        String codigo = (String) session.getAttribute("cod");
        String cargo = (String) session.getAttribute("cargo");
        String user = (String) session.getAttribute("userDB");
        String pass = (String) session.getAttribute("passDB");
        String ip = (String) session.getAttribute("ipDB");
        String url = "jdbc:oracle:thin:@" + ip;

        String idInvEquipo = request.getParameter("idInvEquipo");

        Date td = new Date();                                        
        SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd");
        SimpleDateFormat formatHourFichero = new SimpleDateFormat("hhmmss");
        SimpleDateFormat formatHour = new SimpleDateFormat("HH:mm:ss");
        String b = format.format(td);
        String hour = formatHour.format(td);
        String hourFichero = formatHourFichero.format(td);

        
        ArrayList<String> parameters = new ArrayList<>();

//        String algo = request.getParameter("fecha");
         //String algo =parameters.get(2);
         
         
        if (session.getAttribute("usuario") == null || session.isNew()) {
            response.sendRedirect("sesionExpirada.jsp");
            return;
        }

        if (!cargo.equals("JEFE") && !cargo.equals("ASISTENTE")) {
            response.sendRedirect("sesionInvalida.jsp");
            return;
        }

//        boolean isMultipart = ServletFileUpload.isMultipartContent(request);
//        if (isMultipart) {
//            FileItemFactory factory = new DiskFileItemFactory();
//            ServletFileUpload upload = new ServletFileUpload(factory);
//
//            try {
//                List<FileItem> items = upload.parseRequest(request);
//                String key = "";
//
//                for (FileItem item : items) {
//                    if (!item.isFormField()) {
//                        String ruta = getServletContext().getRealPath("/image/promanet/inventario/");
//                        File fichero = new File(ruta, hourFichero + item.getName());
//                        key = hourFichero + item.getName();
//                        item.write(fichero);
//                    } else {
//                        parameters.add(item.getString());
//                    }
//                }
//            } catch (Exception e) {
//                e.printStackTrace();
//            }
//        }



        if (parameters.size() < 16) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "No se proporcionaron suficientes parámetros.");
            System.out.println(idInvEquipo);
            System.out.println(parameters.indexOf(15));
            return;
        }

        String sql = "UPDATE INV_EQUIPOS SET FECHACOMPRA = TO_DATE(?, 'yyyy-mm-dd hh24:mi:ss'), UBICACIONOFICINA = ?, " +
                     "DEPARTAMENTO = ?, MARCA = ?, MODELO = ?, SERIAL = ?, PROCESADOR = ?, HDD = ?, RAM = ?, " +
                     "PANTALLA = ?, OBSERVACIONES = ?, ESTADO = ?, EMPRESA = ?, DISPOSITIVO = ?, FICHERO = ? " +
                     "WHERE IDINVEQUIPO = ?";

        try (Connection cn = DriverManager.getConnection(url, user, pass);
             PreparedStatement st = cn.prepareStatement(sql)) {

            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
            st.setString(1, parameters.get(0) + " " + hour);
            st.setString(2, parameters.get(2));
            st.setString(3, parameters.get(3));
            st.setString(4, parameters.get(5));
            st.setString(5, parameters.get(6));
            st.setString(6, parameters.get(7));
            st.setString(7, parameters.get(8));
            st.setString(8, parameters.get(9));
            st.setString(9, parameters.get(10));
            st.setString(10, parameters.get(11));
            st.setString(11, parameters.get(15));
            st.setString(12, parameters.get(12));
            st.setString(13, parameters.get(1));
            st.setString(14, parameters.get(4));
            String key = null;
            st.setString(15, key);
            st.setString(16, idInvEquipo);

            st.executeUpdate();
            cn.commit();
        } catch (Exception e) {
            e.printStackTrace();
        }

        if (parameters.get(12).equals("A")) {
            // Additional logic if needed
        } else {
            String sql3 = "UPDATE INV_ASIGNACION SET ESTADO = 'I', FECHADEVOLUCION = TO_DATE(?, 'yyyy-mm-dd hh24:mi:ss') " +
                          "WHERE IDINVEQUIPO = ? AND IDUSUARIO = ? AND ESTADO = 'A'";

            try (Connection cn3 = DriverManager.getConnection(url, user, pass);
                 PreparedStatement st3 = cn3.prepareStatement(sql3)) {

                DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
                st3.setString(1, b + " " + hour);
                st3.setString(2, idInvEquipo);
                st3.setString(3, parameters.get(14));

                st3.executeUpdate();
                cn3.commit();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        
        response.sendRedirect("../ProMaNet/Inventario/INV_Equipos.jsp");

//        response.sendRedirect("../ProMaNet/Inventario/INV_Equipos.jsp");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    public String getServletInfo() {
        return "Short description";
    }
}
