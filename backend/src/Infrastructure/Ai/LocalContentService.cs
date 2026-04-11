namespace Infrastructure.Ai;

/// <summary>
/// Offline replacement for AnthropicClient.
/// Picks from curated Spanish situationist content pools — no external API calls.
/// </summary>
public sealed class LocalContentService : IAnthropicClient
{
    private static readonly Random _rng = Random.Shared;

    // ── Event templates ────────────────────────────────────────────────────────
    private static readonly (string Title, string Description, string ActionType, string InterventionLevel)[] _eventTemplates =
    [
        // Performativa
        ("Silencio Colectivo", "Reúnete con otros en un espacio público y permanece en silencio durante 10 minutos. Observa cómo reacciona el entorno.", "Performativa", "Bajo"),
        ("El Último Paso", "Camina exactamente 100 pasos desde aquí en cualquier dirección y detente. Describe lo que ves.", "Performativa", "Bajo"),
        ("Eco Urbano", "Imita discretamente el sonido más curioso que escuches en los próximos 5 minutos.", "Performativa", "Bajo"),
        ("Teatro Sin Público", "Representa una escena de 2 minutos sobre tu trayecto del día en el lugar donde estés.", "Performativa", "Medio"),
        ("Espejo Ciudadano", "Copia durante 3 minutos los movimientos de la primera persona que pase.", "Performativa", "Medio"),
        ("Manifiesto Efímero", "Escribe en papel tu regla personal para vivir la ciudad hoy. Léela en voz alta y destrúyela.", "Performativa", "Medio"),
        ("Coreografía de Cola", "En la próxima fila o cola que hagas, añade un gesto repetitivo y sutil a cada paso que des.", "Performativa", "Medio"),
        ("Flash Filosófico", "Organiza una conversación de 15 minutos sobre el concepto de 'deriva' con desconocidos dispuestos.", "Performativa", "Alto"),
        ("Intervención Sonora", "Reproduce o canta algo en un espacio público durante exactamente 2 minutos.", "Performativa", "Alto"),
        ("El Coleccionista", "Recoge 5 objetos efímeros del suelo (papeles, hojas, tickets). Construye algo con ellos y abandónalo.", "Performativa", "Alto"),
        ("Mapa Afectivo", "Dibuja a mano el mapa de tus emociones en el espacio donde estás. Déjalo en algún lugar visible.", "Performativa", "Alto"),
        ("Deriva Guiada", "Lidera a un grupo de al menos 3 personas por un recorrido improvisado de 20 minutos sin destino fijo.", "Performativa", "Alto"),

        // Social
        ("Pregunta Extraña", "Haz una pregunta absurda pero amable a la siguiente persona con la que interactúes.", "Social", "Bajo"),
        ("Intercambio de Rutas", "Pide a alguien su camino habitual hacia cualquier lugar. Comparte el tuyo.", "Social", "Bajo"),
        ("El Objeto Prestado", "Pide prestado algo pequeño a un desconocido (un bolígrafo, una moneda) y devuélvelo en 5 minutos.", "Social", "Bajo"),
        ("Saludo Nuevo", "Inventa un saludo único y úsalo con la próxima persona que conozcas.", "Social", "Bajo"),
        ("Nombre de Calle", "Pregunta a alguien el significado o historia del nombre de la calle donde están.", "Social", "Bajo"),
        ("Vecino Desconocido", "Entrega una nota de bienvenida escrita a mano a alguien que no conozcas en el barrio.", "Social", "Medio"),
        ("Historia Colectiva", "Escribe una historia de una frase con al menos 3 desconocidos, cada uno añade una línea.", "Social", "Medio"),
        ("El Trueque", "Ofrece un objeto que lleves encima a cambio de algo que tenga el otro, sin dinero.", "Social", "Medio"),
        ("Guía Local", "Pide a alguien que te muestre su lugar favorito en un radio de 200 metros.", "Social", "Medio"),
        ("Asamblea Efímera", "Convoca a desconocidos para decidir colectivamente qué debería cambiar en este espacio.", "Social", "Alto"),
        ("Red de Favores", "Crea una cadena de al menos 5 favores entre desconocidos en el mismo espacio.", "Social", "Alto"),
        ("El Testigo", "Pide a 5 personas que describan lo que ven en el mismo punto exacto. Comparte los resultados.", "Social", "Alto"),
        ("Manifiesto Vecinal", "Redacta colectivamente con desconocidos una declaración sobre el barrio en 30 minutos.", "Social", "Alto"),

        // Sensorial
        ("Mapa Sonoro", "Cierra los ojos 2 minutos. Escribe todos los sonidos que has identificado por capas.", "Sensorial", "Bajo"),
        ("Textura del Día", "Toca 10 superficies distintas en 5 minutos. ¿Cuál es la más inesperada?", "Sensorial", "Bajo"),
        ("Olores del Barrio", "Identifica y anota 5 olores distintos en un radio de 50 metros.", "Sensorial", "Bajo"),
        ("Luz y Sombra", "Encuentra el contraste de luz más extremo que puedas ver desde donde estás.", "Sensorial", "Bajo"),
        ("Deriva Ciega", "Camina 5 minutos con los ojos cerrados (con ayuda de alguien). ¿Qué percibes?", "Sensorial", "Medio"),
        ("El Ritmo de la Ciudad", "Graba o memoriza el ritmo sonoro del lugar. ¿Hay patrón?", "Sensorial", "Medio"),
        ("Temperatura Urbana", "Encuentra el lugar más cálido y el más frío en 100 metros. Descríbelos.", "Sensorial", "Medio"),
        ("Paleta Cromática", "Anota los 7 colores dominantes del espacio. Ordénalos por intensidad emocional.", "Sensorial", "Medio"),
        ("Instalación Efímera", "Reorganiza elementos del entorno (sin dañarlos) para crear una experiencia sensorial nueva.", "Sensorial", "Alto"),
        ("Concierto Urbano", "Compón una pieza de 3 minutos usando solo los sonidos del entorno. Interpreta.", "Sensorial", "Alto"),
        ("Deriva Sinestésica", "Asigna un color a cada sonido que escuches durante 15 minutos. Dibuja el resultado.", "Sensorial", "Alto"),

        // Poetica
        ("Haiku Urbano", "Escribe un haiku (5-7-5 sílabas) sobre lo que tienes delante ahora mismo.", "Poetica", "Bajo"),
        ("La Palabra Perdida", "Encuentra una palabra escrita en el entorno y construye un poema de 4 versos a partir de ella.", "Poetica", "Bajo"),
        ("Epitafio de Lugar", "Escribe el epitafio de este lugar si desapareciera mañana.", "Poetica", "Bajo"),
        ("Carta al Barrio", "Escribe una carta de 3 párrafos dirigida a este barrio como si fuera una persona.", "Poetica", "Bajo"),
        ("El Nombre Verdadero", "Inventa el nombre que debería tener este lugar según lo que transmite.", "Poetica", "Bajo"),
        ("Palimpsesto Urbano", "Reescribe la historia de una fachada o muro como si fuera un poema épico.", "Poetica", "Medio"),
        ("Diálogo Con el Espacio", "Mantén una conversación escrita de 10 intercambios con el lugar donde estás.", "Poetica", "Medio"),
        ("El Manifiesto Mínimo", "En 10 palabras exactas, describe la filosofía de vida que este espacio sugiere.", "Poetica", "Medio"),
        ("Poema de Tránsito", "Escribe un poema usando solo palabras que veas escritas en señales o carteles cercanos.", "Poetica", "Medio"),
        ("La Elegía", "Escribe una elegía por algo que ya no existe en este lugar.", "Poetica", "Medio"),
        ("Novela en Miniatura", "Escribe una historia completa de exactamente 100 palabras inspirada en este entorno.", "Poetica", "Alto"),
        ("El Gran Manifiesto", "Redacta un manifiesto situacionista de 500 palabras sobre el uso libre de la ciudad.", "Poetica", "Alto"),
        ("La Autobiografía del Edificio", "Escribe la historia de vida de un edificio cercano desde su perspectiva.", "Poetica", "Alto"),
        ("Traducción Imposible", "Traduce la atmósfera de este lugar a música, a un color, a una receta y a un movimiento corporal.", "Poetica", "Alto"),

        // Instalacion
        ("El Objeto Fuera de Lugar", "Coloca un objeto cotidiano fuera de su contexto habitual y observa la reacción del espacio durante 10 minutos.", "Instalacion", "Bajo"),
        ("Señal Inventada", "Crea una señal urbana falsa (en papel) y colócala en un lugar lógico. Retírala antes de irte.", "Instalacion", "Medio"),
        ("Jardín Efímero", "Construye una pequeña instalación con materiales naturales encontrados. Desaparecerá sola.", "Instalacion", "Medio"),
        ("Archivo del Suelo", "Fotografía o dibuja 20 detalles del suelo en 100 metros. Expón el resultado en el mismo lugar.", "Instalacion", "Alto"),
    ];

    // ── Deriva instructions ───────────────────────────────────────────────────
    private static readonly Dictionary<string, string[]> _derivaInstructions = new(StringComparer.OrdinalIgnoreCase)
    {
        ["Caotica"] =
        [
            "Camina hacia el sonido más extraño que escuches.",
            "Toma la próxima calle a la derecha, luego la segunda a la izquierda.",
            "Sigue a alguien con paraguas durante exactamente dos minutos.",
            "Camina en la dirección opuesta a la que ibas.",
            "Busca un portal abierto y entra. Sal por donde puedas.",
            "Cuenta 23 pasos y gira hacia donde haya más sombra.",
            "Sigue la línea de un bordillo hasta que se curve.",
            "Encuentra el callejón más estrecho visible y recórrelo.",
            "Observa el cielo 30 segundos. Muévete en la dirección a la que apuntaba la última nube.",
            "Cruza la calle en el punto más alejado del paso de cebra.",
            "Sigue al primer animal que veas.",
            "Camina de espaldas durante 20 pasos.",
            "Entra en el primer establecimiento abierto con más de una persona dentro.",
            "Busca una escalera que no hayas visto antes y súbela.",
            "Sigue la sombra más larga que puedas ver.",
        ],
        ["Poetica"] =
        [
            "Encuentra un árbol y quédate bajo su copa exactamente tres minutos.",
            "Camina hasta el edificio más antiguo visible desde aquí.",
            "Busca un lugar donde el tiempo parezca haberse detenido.",
            "Sigue el recorrido del agua: desagüe, fuente o lluvia.",
            "Camina hacia el lugar donde hay menos luz artificial.",
            "Encuentra un umbral entre dos mundos distintos y detente en él.",
            "Busca una ventana iluminada y imagina la vida que hay detrás.",
            "Camina hacia el sonido que te resulte más melancólico.",
            "Encuentra el espacio más vacío en un radio de 200 metros.",
            "Sigue las grietas del suelo como si fueran un río.",
            "Busca el lugar donde la ciudad parece respirar más despacio.",
            "Camina hasta encontrar algo que te resulte completamente inútil y hermoso.",
            "Sigue el contorno de una sombra proyectada sobre el suelo.",
            "Encuentra un banco o asiento sin nadie y siéntate a escuchar.",
            "Camina hacia la fuente del olor más evocador que percibas.",
        ],
        ["Social"] =
        [
            "Pregunta a la siguiente persona que veas cómo se llama este barrio para ella.",
            "Encuentra a alguien que lleve tiempo sentado en el mismo lugar y preséntate.",
            "Pide indicaciones para ir a un lugar que ya conoces.",
            "Pregunta a alguien cuál es su rincón favorito cerca de aquí.",
            "Observa al grupo de personas más numeroso visible y acércate con una excusa.",
            "Pregunta a un comerciante qué recuerda de este lugar hace diez años.",
            "Ofrece a alguien una pregunta en lugar de un saludo.",
            "Encuentra a alguien que cargue algo pesado y ofrece tu ayuda.",
            "Pregunta a alguien qué hora es aunque tengas reloj y comenta el resultado.",
            "Busca a alguien que esté esperando algo y comparte su espera.",
            "Pregunta a alguien cuál es la calle más interesante del barrio y por qué.",
            "Encuentra a alguien con un libro y pregúntale de qué trata.",
            "Pide a alguien que te cuente una historia de este lugar.",
            "Busca a alguien que esté mirando el cielo y pregúntale qué ve.",
            "Pregunta a alguien mayor qué echaba de menos antes de que existiera esto.",
        ],
        ["Sensorial"] =
        [
            "Cierra los ojos 60 segundos. Luego muévete hacia el sonido más cercano.",
            "Busca la superficie más fría que puedas tocar en el espacio visible.",
            "Identifica el olor dominante y camina hacia su origen.",
            "Encuentra el lugar con el eco más notable en 100 metros.",
            "Toca cinco texturas distintas en el próximo minuto y sigue hacia la más suave.",
            "Busca el punto de máxima vibración del suelo (tráfico, metro, maquinaria).",
            "Localiza la fuente de luz más cálida visible y dirígete a ella.",
            "Encuentra el contraste sonoro más extremo: silencio junto a ruido.",
            "Camina siguiendo el patrón de temperatura: busca el gradiente frío-cálido.",
            "Identifica el ritmo más repetitivo del entorno y sincroniza tus pasos con él.",
            "Busca el lugar donde convergen más colores diferentes.",
            "Encuentra la textura más inesperada que puedas tocar.",
            "Sigue el sendero de mayor intensidad luminosa.",
            "Busca el punto donde el ruido se convierte en música.",
            "Camina hacia donde el viento sea más perceptible.",
        ],
    };

    public Task<EventDraft> GenerateEventSuggestionAsync(EventContext context, CancellationToken ct = default)
    {
        // Filter by ActionType if there's a matching entry, otherwise use the full pool
        var pool = _eventTemplates
            .Where(t => string.Equals(t.ActionType, context.ActionType, StringComparison.OrdinalIgnoreCase))
            .ToArray();

        if (pool.Length == 0)
            pool = _eventTemplates;

        var pick = pool[_rng.Next(pool.Length)];
        return Task.FromResult(new EventDraft(pick.Title, pick.Description, pick.ActionType, pick.InterventionLevel));
    }

    public Task<DerivaInstructionResult> GenerateDerivaInstructionAsync(DerivaContext context, CancellationToken ct = default)
    {
        var pool = _derivaInstructions.TryGetValue(context.DerivaType, out var instructions)
            ? instructions
            : _derivaInstructions["Caotica"];

        return Task.FromResult(new DerivaInstructionResult(pool[_rng.Next(pool.Length)]));
    }

    public Task<ModerationResult> ModerateContentAsync(string content, CancellationToken ct = default)
        => Task.FromResult(new ModerationResult(true, null));
}
