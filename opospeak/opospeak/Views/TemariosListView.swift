//
//  TemariosListView.swift
//  opospeak
//
//  Created by David de León Acosta on 11/06/2026.
//

import SwiftUI
import SwiftData

struct TemariosListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<Temario> { $0.activo }, sort: \Temario.fechaCreacion)
    private var temarios: [Temario]

    @State private var mostrandoCreacion = false

    var body: some View {
        List {
            ForEach(temarios) { temario in
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
        .navigationTitle("Temarios")
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
            NuevoTemarioSheet()
        }
        .overlay {
            if temarios.isEmpty {
                ContentUnavailableView {
                    Label("Sin temarios", systemImage: "books.vertical")
                } description: {
                    Text("Crea tu primer temario para empezar a organizar tu práctica oral.")
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
                } footer: {
                    Text("Por ejemplo: Judicatura, Notarías, Inspección de Hacienda.")
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
        let limpio = nombre.trimmingCharacters(in: .whitespacesAndNewlines)
        let desc = descripcion.trimmingCharacters(in: .whitespacesAndNewlines)
        let temario = Temario(nombre: limpio, descripcion: desc.isEmpty ? nil : desc)
        modelContext.insert(temario)
        dismiss()
    }
}

#Preview("Con temarios") {
    let container = try! ModelContainer(
        for: Temario.self, Tema.self, Sesion.self, Intento.self,
        Grabacion.self, Metrica.self, Nota.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let temario = Temario(nombre: "Judicatura")
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
        for: Temario.self, Tema.self, Sesion.self, Intento.self,
        Grabacion.self, Metrica.self, Nota.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    return NavigationStack {
        TemariosListView()
    }
    .modelContainer(container)
    .environment(AppEnvironment(modo: .local))
}
