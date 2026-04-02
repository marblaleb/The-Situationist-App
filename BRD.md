# 📄 BRD — App de Eventos Situacionistas

## 1. 🧠 Visión del producto

Crear una aplicación móvil que permita a los usuarios generar, descubrir y participar en experiencias urbanas efímeras inspiradas en la psicogeografía y el pensamiento situacionista.

La app no busca optimizar la eficiencia ni el consumo de eventos, sino provocar:
- Exploración urbana
- Interacciones inesperadas
- Ruptura de la rutina cotidiana

---

## 2. 🎯 Objetivos

### Objetivos principales
- Facilitar la creación de eventos efímeros y experimentales
- Generar experiencias urbanas impredecibles
- Fomentar la participación activa (no consumo pasivo)

### Objetivos secundarios
- Crear una capa “oculta” de experiencias sobre la ciudad
- Evitar dinámicas típicas de redes sociales (likes, seguidores)

---

## 3. 👥 Roles de usuario

### 3.1 Usuario explorador
- Navega eventos
- Participa en experiencias
- Usa modo deriva y misiones

### 3.2 Usuario creador
- Crea eventos situacionistas
- Usa generador automático de ideas
- Define reglas y duración

### 3.3 Sistema (IA)
- Genera eventos automáticamente
- Modera contenido
- Sugiere acciones y misiones
- Ajusta dificultad/contexto

### 3.4 Moderador (opcional futuro)
- Revisa contenido reportado
- Ajusta reglas del sistema

---

## 4. 🧩 Features principales

## 4.1 Sistema de creación de eventos
- Crear eventos con:
  - Ubicación aproximada (radio)
  - Duración limitada
  - Tipo de acción
  - Nivel de intervención

- Generador automático:
  - Combina acción + contexto + restricción
  - Botón “Sorpréndeme”

- Mutación de eventos:
  - Permite modificar eventos existentes

---

## 4.2 Modo Deriva
- Generación de instrucciones aleatorias en tiempo real
- Tipos de deriva:
  - Caótica
  - Poética
  - Social
  - Sensorial

- Inputs contextuales:
  - Hora
  - Ubicación
  - Movimiento del usuario

- Sin mapa visible durante la experiencia

---

## 4.3 Modo Mapa
- Visualización de eventos cercanos
- Eventos representados como:
  - Elementos dinámicos (latidos, glitch)

- Tipos de visibilidad:
  - Visible global
  - Visible por proximidad
  - Oculto hasta descubrimiento

---

## 4.4 Modo Misiones (retos)
- Sistema de pistas encadenadas
- Geolocalización indirecta
- Progreso no lineal

- Tipos de pistas:
  - Textuales
  - Sensoriales
  - Contextuales

---

## 4.5 Acciones efímeras
- Eventos con:
  - Tiempo de vida limitado (TTL)
  - Número máximo de participantes

- Eventos flash:
  - Aparición/desaparición rápida

---


---

## 4.7 Huella situacionista (perfil)
- Registro de experiencias vividas
- Métricas no tradicionales:
  - Nivel de deriva
  - Interacciones urbanas
  - Exploración

- Sin:
  - Likes
  - Seguidores
  - Comentarios públicos

---

## 4.8 Sistema de roles temporales
- Roles asignados durante experiencias:
  - Observador
  - Agente del caos
  - Invisible

---

## 4.9 Eventos encadenados
- Un evento desbloquea otro
- Posibilidad de narrativa emergente

---

## 5. 🧭 UX / UI (resumen funcional)

### Navegación principal:
- Mapa
- Deriva
- Misiones
- Crear

### Principios:
- Interfaz minimalista
- Información limitada
- Interacción simple
- Estética experimental controlada

---

## 6. ⚙️ Reglas de negocio

### 6.1 Creación de eventos
- Duración máxima configurable (ej: 60 min)
- Ubicación siempre aproximada (no exacta)
- Contenido debe cumplir normas de seguridad

---

### 6.2 Participación
- Usuario puede:
  - Participar
  - Observar
  - Ignorar

- Límite de participantes por evento (opcional)

---

### 6.3 Visibilidad
- Eventos pueden:
  - Ser públicos
  - Ser geolocalizados
  - Ser ocultos hasta proximidad

---

### 6.4 Persistencia
- Eventos se eliminan tras expirar
- No existe archivo público completo
- Solo historial personal

---

### 6.5 Moderación
- Filtrado automático:
  - Violencia
  - Actividad ilegal
  - Acoso

- Sistema de reportes

---

### 6.6 Reputación
- No hay puntuaciones numéricas tradicionales
- Métricas cualitativas internas

---

## 7. ⚠️ Edge Cases

### 7.1 Seguridad
- Evento incita comportamiento peligroso
- Usuario sigue instrucciones inapropiadas en deriva
- Interacciones con desconocidos → riesgo

Mitigación:
- Filtros IA
- Límites de contenido
- Mensajes de advertencia

---

### 7.2 Ubicación
- GPS impreciso
- Usuario en zona sin cobertura
- Eventos en lugares inaccesibles

Mitigación:
- Radios amplios
- Fallback offline
- Validación básica de ubicación

---

### 7.3 Abuso del sistema
- Spam de eventos
- Trolls creando experiencias absurdas dañinas
- Uso repetitivo del generador

Mitigación:
- Rate limiting
- Sistema de confianza
- Penalizaciones invisibles

---

### 7.4 Experiencia rota
- Demasiados eventos → saturación
- Muy pocos eventos → app vacía

Mitigación:
- Generación automática
- Curación dinámica

---

### 7.5 Misiones
- Pistas demasiado difíciles o imposibles
- Usuario no entiende instrucciones

Mitigación:
- Sistema de pistas progresivas
- Opciones de ayuda

---

### 7.6 Deriva
- Instrucciones imposibles según contexto
- Usuario en movimiento limitado (ej: coche, casa)

Mitigación:
- Adaptación contextual
- Re-roll de instrucciones

---


## 8. 📊 Métricas de éxito

- Número de eventos creados por día
- Ratio participación/evento
- Tiempo medio en modo deriva
- Número de misiones completadas
- Retención sin sistema de recompensas clásico

---

## 9. 🚀 Futuras extensiones

- Integración con artistas urbanos
- Eventos sincronizados masivos
- Capas narrativas persistentes
- IA más avanzada para generación de experiencias

---

