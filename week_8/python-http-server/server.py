from http.server import HTTPServer, BaseHTTPRequestHandler

class SimpleHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        # Enviem el codi de resposta 200 (OK)
        self.send_response(200)
        # Indiquem que el contingut és text pla
        self.send_header('Content-type', 'text/plain')
        self.end_headers()
        # Escrivim el missatge
        self.wfile.write(b"Hello from container\n")

def run(server_class=HTTPServer, handler_class=SimpleHandler, port=8080):
    server_address = ('', port)
    httpd = server_class(server_address, handler_class)
    print(f"Servidor funcionant al port {port}...")
    httpd.serve_forever()

if __name__ == '__main__':
    run()