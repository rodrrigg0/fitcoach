# FitCoach - AI Personal Fitness Assistant

Aplicación multiplataforma completa de entrenamiento personal. Genera planes de fitness y nutrición personalizados con IA, seguimiento de progreso y asesoramiento 24/7.

## 🛠️ Stack

- **Frontend**: Flutter 3.0+ (Dart)
- **Arquitectura**: Clean Architecture
- **Estado**: Provider / Riverpod
- **Backend/Datos**: Firebase (Auth, Firestore, Storage)
- **IA**: Claude API + OpenAI
- **Plataformas**: Android, iOS, Web, Windows, Linux, macOS

## 🎯 Funcionalidades

- Onboarding inteligente con chat IA
- Autenticación con Firebase (email, Google, Apple)
- Generación automática de planes de entrenamiento personalizados
- Módulo de nutrición con macros y calorías
- Chat IA 24/7 para asesoramiento fitness
- Seguimiento de progreso con gráficas y estadísticas
- Notificaciones push de recordatorios
- Modo offline con sincronización

## 🏗️ Arquitectura

Clean Architecture con 3 capas:
- **Presentation**: Screens, Widgets, Estado (Provider/Riverpod)
- **Domain**: Entities, Repositorios abstractos, Use Cases
- **Data**: Firebase Datasources, Mappers, Implementación de Repositorios

## 🤖 Integración con Claude API

El núcleo inteligente de FitCoach utiliza Claude API para:
- **Onboarding conversacional**: Chat natural que entiende contexto del usuario
- **Generación de planes**: Creación de rutinas y dietas personalizadas con IA
- **Adaptación dinámica**: Ajuste de planes según progreso y retroalimentación
- **Chat 24/7**: Asistente que responde preguntas sobre fitness, nutrición y lesiones
- **Análisis contextual**: Entiende historial completo del usuario para recomendaciones precisas

---
