//
//  ProgresoView.swift
//  opospeak
//
//  Created by David de León Acosta on 11/06/2026.
//

import SwiftUI
import SwiftData

// Vista editorial, no panel de control: hechos, sin juicios ni rachas
// (define-progress-and-history-model).
struct ProgresoView: View {
    @Query(sort: \Oposicion.fechaCreacion) private var oposiciones: [Oposicion]
    @Query private var intentos: [Intento]
    @Query(filter: #Predicate<Tema> { $0.activo }) private var temas: [Tema]

    private var oposicionActiva: Oposicion? {
        if let idString = UserDefaults.standard.string(forKey: OposicionActiva.storageKey),
           let id = UUID(uuidString: idString),
           let elegida = oposiciones.first(where: { $0.id == id }) {
            return elegida
        }
        return oposiciones.first
    }

    // El progreso se calcula sobre la oposición activa: con una sola
    // oposición es idéntico al global, pero la semántica queda correcta.
    private var temasActivos: [Tema] {
        guard let activa = oposicionActiva else { return [] }
        return temas.filter { $0.temario?.oposicion?.id == activa.id }
    }

    private var intentosActivos: [Intento] {
        guard let activa = oposicionActiva else { return [] }
        return intentos.filter { $0.tema?.temario?.oposicion?.id == activa.id }
    }

    private var resumen: ProgressSummary {
        ProgressSummary(
            intentos: intentosActivos.map {
                .init(fecha: $0.fechaInicio, duracion: $0.duracionReal, temaId: $0.tema?.id ?? UUID())
            },
            temaIds: temasActivos.map(\.id)
        )
    }

    private func tema(con id: UUID) -> Tema? {
        temasActivos.first { $0.id == id }
    }

    var body: some View {
        List {
            if resumen.hayActividad {
                Section("Volumen") {
                    LabeledContent("Intentos", value: "\(resumen.totalIntentos)")
                    LabeledContent("Tiempo acumulado", value: formatearDuracion(resumen.tiempoAcumulado))
                    LabeledContent("Temas trabajados", value: "\(resumen.temasTrabajados)")
                    LabeledContent("Días con práctica", value: "\(resumen.diasActivos)")
                }
                Section("Consistencia") {
                    LabeledContent("Últimos 7 días", value: "\(resumen.diasConPracticaUltimos7) días con práctica")
                    LabeledContent("Últimos 30 días", value: "\(resumen.diasConPracticaUltimos30) días con práctica")
                }
                Section("Cobertura") {
                    LabeledContent("Temas practicados", value: "\(resumen.temasPracticados) de \(resumen.totalTemas)")
                    LabeledContent("Sin practicar todavía", value: "\(resumen.temasNuncaPracticados)")
                }
                Section("Distribución") {
                    if let mas = resumen.temaMasPracticado, let tema = tema(con: mas.temaId) {
                        LabeledContent("Más practicado") {
                            Text("\(tema.nombreVisible) · \(mas.intentos) intentos")
                        }
                    }
                    if let menos = resumen.temaMenosPracticado, let tema = tema(con: menos.temaId) {
                        LabeledContent("Menos practicado") {
                            Text("\(tema.nombreVisible) · \(menos.intentos) intentos")
                        }
                    }
                }
            }
        }
        .fondoEditorial()
        .navigationTitle("Progreso")
        .overlay {
            if !resumen.hayActividad {
                ContentUnavailableView {
                    Label("Todavía sin progreso", systemImage: "chart.line.uptrend.xyaxis")
                } description: {
                    Text("Tu progreso aparecerá aquí a medida que practiques tus temas. Empieza desde la pestaña Temarios.")
                }
            }
        }
    }
}

#Preview {
    let container = try! ModelContainer(
        for: Oposicion.self, Temario.self, Tema.self, Sesion.self, Intento.self,
        Grabacion.self, Metrica.self, Nota.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    return NavigationStack {
        ProgresoView()
    }
    .modelContainer(container)
}
