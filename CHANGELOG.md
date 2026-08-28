# Novedades

Lo que cambia en cada versión de `meto2`, contado para quien la usa.

Reglas: una sección `## X.Y.Z` por versión, la más nueva arriba, una viñeta por
cambio, en castellano y sin jerga. Se escribe **en el mismo commit que lo
implementa**, no al publicar.

## 0.1.0 — sin publicar

- **`/arrancar` te deja el método entero en cualquier carpeta.** Ocho archivos
  —cinco para leer y tres de plomería— y cuatro carpetas, más la memoria del
  proyecto arrancada y el `.mcp.json` apuntando a esa carpeta. No hace `git init` ni instala nada: el proyecto ya
  existe, esto le agrega la forma de trabajar encima. Correrlo dos veces no pisa
  nada: lo que ya estaba se nombra y se deja como estaba
- **Los archivos llegan con preguntas, no con respuestas.** Una sección en blanco
  es honesta; una respuesta inventada es una mentira sobre la que el próximo
  agente va a actuar. Lo único que hay que hacer a mano es contestarlas
- **`/arrancar` te pregunta una sola vez qué herramientas necesita este
  proyecto**, leyendo en vivo lo que tenés instalado. Las cuatro del método
  quedan encendidas y **todo lo demás arranca apagado**: una herramienta
  encendida de más cuesta contexto en cada sesión y no se nota, una apagada de
  más cuesta un renglón el día que la extrañás, y ese día es obvio. Medido: son
  ~6.000 tokens menos por sesión, y no se ve hasta que reinicies
- **`/cerrar` te dice al final del día qué quedó sin escribir, y nunca lo escribe
  él.** Comprueba lo que ya está activo y —esto es lo importante— te pregunta si
  ya se cumplió el disparador de lo que todavía no. La parte que falta del método
  no depende de que alguien se acuerde: se pregunta sola en cada cierre
- **`/simple` vuelve a explicar la última respuesta para vos.** Sin recortar la
  parte difícil: traduce los términos donde aparecen y arranca por lo que
  significa para quien lee
- **Cada proyecto se acuerda solo de para quién escribir.** Un recordatorio se
  dispara con cada mensaje y manda a releer a quién le estás hablando. No lleva
  tu descripción adentro: apunta al archivo donde la escribiste vos, así no queda
  desactualizado nunca
- **El método se lee solo, en cualquier herramienta.** Vive en `AGENTS.md`, que
  es el nombre que también leen otros agentes además de Claude Code
- **La memoria se genera, no se escribe a mano.** Si a una memoria le falta un
  campo, el generador la nombra y falla — pero **no la esconde**: queda igual en
  el índice, marcada. Nunca desaparece algo por un campo mal escrito
- **`bash instalar.sh` te deja todo listo en una computadora**, con una sola
  pregunta antes de bajar nada, diciendo qué baja y de dónde. Termina siempre con
  tres partes: qué instaló, qué no pudo **y por qué**, y qué te toca a vos con el
  comando exacto para copiar
- **El índice de specs que se crea en cada proyecto mandaba a leer un archivo
  que no existe.** Decía `AGENT.md` cuando el archivo del método es `AGENTS.md`.
  Los archivos se creaban perfectos y todas las pruebas pasaban: lo que estaba
  mal era una frase, y un agente la iba a repetir tal cual
- **`/cerrar` ahora pregunta también por la arquitectura, y siempre pregunta.**
  Faltaban dos cosas. Una: comprobaba guía, changelog, memoria y cicatrices,
  pero nunca si la sección de `AGENTS.md` que describe qué hace cada carpeta
  seguía siendo cierta — que es lo que se pudre en silencio, porque un agente
  que lee un renglón viejo no pregunta, inventa. Ahora te muestra qué carpetas
  recibieron archivos nuevos y te hace la pregunta. Dos: si el día estaba
  tranquilo, el comando terminaba sin ofrecer nada y vos no sabías si era que no
  había nada o que se había olvidado. Ahora cierra siempre con *"¿escribo
  alguna? memoria / guía / arquitectura / changelog / nada"*
- **Las plantillas ya no le imponen el castellano a tu proyecto.** El `CHANGELOG`
  y la guía que `/arrancar` deja llegaban con el andamiaje escrito en
  rioplatense; las otras cuatro plantillas venían en inglés. Ahora llegan las
  seis en inglés, y cada una te dice adentro que **lo que escribas** vaya en el
  idioma que declaraste, no en el de ellas. La diferencia importa: el andamiaje
  lo lee un agente, las viñetas las lee un usuario que no tiene a nadie al lado
  para traducirle
- **El instalador ya no se queda mudo mientras baja los complementos.** Antes la
  pantalla quedaba en blanco medio minuto y lo razonable era pensar que se
  habia colgado. Ahora va diciendo `[2/4] bajando ponytail...`. Es un contador y
  no una ruedita girando a proposito: si algo se traba, el numero se queda
  quieto y lo ves — una ruedita gira igual de contenta cuando nada funciona
- **La segunda pregunta del instalador se entiende.** La que pide permiso para
  tocar tu configuracion. Antes arrancaba explicando el mecanismo; ahora arranca
  por el problema que arregla —en una carpeta cualquiera Claude te habla como si
  fueras programador— y para deshacerlo ya no hay que buscar un bloque dentro de
  un archivo de configuracion: se lo pedis a Claude en castellano
- **El instalador te avisa que hay que salir y volver a entrar a Claude Code.**
  La lista de comandos la lee una sola vez, al abrir la sesión: sin ese aviso
  escribís `/arrancar`, no aparece, y lo lógico es concluir que la instalación
  falló. Si corriste el instalador desde adentro de Claude Code lo sabe con
  certeza y te lo dice como una orden; si no, te lo dice por las dudas
- **El instalador comprueba que tengas Python antes de empezar, no después.**
  Miraba que estuvieran `git` y `curl`, pero no Python — y lo necesita él mismo,
  y lo necesitan `/arrancar` y `/cerrar`. En una Mac recién sacada de la caja eso
  terminaba en el peor final posible: la instalación decía **listo**, y el
  problema aparecía más tarde y disfrazado de otra cosa. Ahora frena en el primer
  segundo y te da el comando exacto para arreglarlo
