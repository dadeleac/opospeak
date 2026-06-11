//
//  TemariosListView.swift
//  opospeak
//
//  Created by David de León Acosta on 11/06/2026.
//

import SwiftUI
import SwiftData

// Temarios de la oposición activa. El título de navegación es el nombre
// de la oposición (Judicatura arriba, sus temarios debajo): la jerarquía
// Oposición → Temarios → Temas se lee tal cual.
struct TemariosListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Oposicion.fechaCreacion)
    private var oposiciones: [Oposicion]
    @Query(filter: #Predicate<Temario> { $0.activo }, sort: \Temario.fechaCreacion)
    private var temarios: [Temario]

    @State private var mostrandoCreacion = false

    private var oposicionActiva: Oposicion? {
        if let idString = UserDefaults.standard.string(forKey: OposicionActiva.storageKey),
           let id = UUID(uuidString: idString),
           let elegida = oposiciones.first(where: { $0.id == id }) {
            return elegida
        }
        return oposiciones.first
    }

    private var temariosVisibles: [Temario] {
        guard let activa = oposicionActiva else { return [] }
        return temarios.filter { $0.oposicion?.id == activa.id }
    }

    var body: some View {
        List {
            ForEach(temariosVisibles) { temario in
                NavigationLink(value: temario) {
                    TemarioRow(temario: temario)
                }
                .swipeActions(edge: .trailing) {
                    Button {
                        archivar(temario)
                    } label: {
                        Label("Archivar", systemImage: "archivebox")
                    }
                    .tint(.ambar)
                }
            }
        }
        .fondoEditorial()
        .navigationTitle(oposicionActiva?.nombre ?? "Temarios")
        .navigationDestination(for: Temario.self) { temario in
            TemarioDetailView(temario: temario)
        }
        .navigationDestination(for: Tema.self) { tema in
            TemaDetailView(tema: tema)
        }
        .navigationDestination(for: Intento.self) { intento in
            IntentoDetailView(intento: intento)
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    mostrandoCreacion = true
                } label: {
                    Label("Crear temario", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $mostrandoCreacion) {
            NuevoTemarioSheet(oposicion: oposicionActiva)
        }
        .overlay {
            if temariosVisibles.isEmpty {
                ContentUnavailableView {
                    Label("Sin temarios", systemImage: "books.vertical")
                } description: {
                    Text("Crea tu primer temario — por ejemplo Civil, Penal o Bloque I — para organizar tus temas.")
                } actions: {
                    Button("Crear temario") {
                        mostrandoCreacion = true
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
    }

    private func archivar(_ temario: Temario) {
        temario.activo = false
        temario.fechaActualizacion = .now
    }
}

private struct TemarioRow: View {
    let temario: Temario

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(temario.nombre)
                .font(.headline)
            HStack(spacing: 12) {
                Text("\(temario.temasActivos.count) temas")
                if let fecha = temario.actividadReciente {
                    Text("Última práctica \(fecha.formatted(date: .abbreviated, time: .omitted))")
                }
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
    }
}

struct NuevoTemarioSheet: View {
    /// Oposición destino; si aún no existe ninguna (caso límite: onboarding
    /// descartado), se crea una por defecto al guardar.
    let oposicion: Oposicion?

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var nombre = ""
    @State private var descripcion = ""

    private var nombreValido: Bool {
        !nombre.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Nombre", text: $nombre)
                        .accessibilityLabel("Nombre del temario")
                } header: {
                    if let oposicion {
                        Text("Nuevo temario de \(oposicion.nombre)")
                    }
                } footer: {
                    Text("Por ejemplo: Civil, Penal, Procesal, Bloque I.")
                }
                Section("Opcional") {
                    TextField("Descripción", text: $descripcion, axis: .vertical)
                        .accessibilityLabel("Descripción del temario")
                }
            }
            .navigationTitle("Nuevo temario")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Crear") { crear() }
                        .disabled(!nombreValido)
                }
            }
        }
    }

    private func crear() {
        let destino: Oposicion
        if let oposicion {
            destino = oposicion
        } else {
            destino = Oposicion(nombre: OposicionBackfill.nombrePorDefecto)
            modelContext.insert(destino)
        }
        let limpio = nombre.trimmingCharacters(in: .whitespacesAndNewlines)
        let desc = descripcion.trimmingCharacters(in: .whitespacesAndNewlines)
        let temario = Temario(
            nombre: limpio,
            descripcion: desc.isEmpty ? nil : desc,
            oposicion: destino
        )
        modelContext.insert(temario)
        dismiss()
    }
}

#Preview("Con temarios") {
    let container = try! ModelContainer(
        for: Oposicion.self, Temario.self, Tema.self, Sesion.self, Intento.self,
        Grabacion.self, Metrica.self, Nota.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let oposicion = Oposicion(nombre: "Judicatura")
    container.mainContext.insert(oposicion)
    let temario = Temario(nombre: "Civil", oposicion: oposicion)
    container.mainContext.insert(temario)
    container.mainContext.insert(Tema(numero: 1, temario: temario))

    return NavigationStack {
        TemariosListView()
    }
    .modelContainer(container)
    .environment(AppEnvironment(modo: .local))
}

#Preview("Vacío") {
    let container = try! ModelContainer(
        for: Oposicion.self, Temario.self, Tema.self, Sesion.self, Intento.self,
        Grabacion.self, Metrica.self, Nota.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    return NavigationStack {
        TemariosListView()
    }
    .modelContainer(container)
    .environment(AppEnvironment(modo: .local))
}
