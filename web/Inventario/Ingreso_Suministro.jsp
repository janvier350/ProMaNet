<%-- 
    Document   : Ingreso_Suministro
    Created on : 6 dic 2024, 3:59:44 p. m.
    Author     : Backup
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Registro de Compras</title>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script>
        // Función para agregar producto a la tabla
        function agregarProducto() {
            const producto = $('#producto').val();
            const cantidad = $('#cantidad').val();

            if (producto && cantidad > 0) {
                // Llamada AJAX para agregar el producto
                $.ajax({
                    url: 'CompraServlet',
                    method: 'POST',
                    data: { action: 'agregar', producto: producto, cantidad: cantidad },
                    success: function(response) {
                        $('#tablaProductos tbody').html(response); // Actualiza la tabla
                        $('#producto').val('');
                        $('#cantidad').val('');
                    }
                });
            } else {
                alert("Por favor, ingrese un producto válido y una cantidad mayor a 0.");
            }
        }

        // Función para eliminar un producto
        function eliminarProducto(index) {
            $.ajax({
                url: 'CompraServlet',
                method: 'POST',
                data: { action: 'eliminar', index: index },
                success: function(response) {
                    $('#tablaProductos tbody').html(response); // Actualiza la tabla
                }
            });
        }
    </script>
</head>
<body>
    <h2>Registro de Compras</h2>
    <form action="../CompraServlet" method="post">
        <div>
            <label>Fecha de Compra:</label>
            <input type="date" name="fechaCompra" required>
        </div>
        <div>
            <label>Fecha de Pedido:</label>
            <input type="date" name="fechaPedido" required>
        </div>
        <div>
            <label>Fecha de Recibido:</label>
            <input type="date" name="fechaRecibido" required>
        </div>
        <h3>Detalle de Productos</h3>
        <div>
            <label>Producto:</label>
            <input type="text" id="producto" required>
            <label>Cantidad:</label>
            <input type="number" id="cantidad" required>
            <button type="button" onclick="agregarProducto()">Agregar</button>
        </div>
        <table id="tablaProductos" border="1">
            <thead>
                <tr>
                    <th>Producto</th>
                    <th>Cantidad</th>
                    <th>Acción</th>
                </tr>
            </thead>
            <tbody>
                <!-- Productos dinámicos aquí -->
            </tbody>
        </table>
        <button type="submit" name="action" value="guardar">Guardar Compra</button>
    </form>
</body>
</html>
