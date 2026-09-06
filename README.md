# Sistema de Procesamiento de Transacciones Financieras

Sistema backend empresarial que procesa transferencias bancarias, detecta fraude en tiempo real y mantiene auditoría completa de operaciones.

## 🛠️ Stack

- **Backend**: Java 11+, Spring Boot
- **Base de Datos**: MySQL
- **DevOps**: Docker, Docker Compose
- **CI/CD**: GitHub Actions
- **Calidad**: SonarQube
- **Frontend**: Flutter (app companion)

## 🎯 Funcionalidades

- Procesamiento de transferencias bancarias con validación multi-capa
- Detección automática de fraude mediante análisis de patrones
- Auditoría completa de todas las operaciones
- Generación de reportes financieros y operacionales
- Integración continua automatizada con GitHub Actions

## 🏗️ Arquitectura

Arquitectura en capas:
- **Controller**: Endpoints REST
- **Service**: Lógica de negocio y validación de fraude
- **Repository**: Acceso a datos con JPA/Hibernate
- **Entity**: Modelos persistentes en MySQL

## 🤖 Integración con Claude API

La aplicación utiliza Claude API para análisis avanzado de patrones de fraude:
- Validación inteligente de transacciones sospechosas
- Generación de reportes de riesgo con análisis contextual
- Sugerencias de mejora en seguridad basadas en IA

---
