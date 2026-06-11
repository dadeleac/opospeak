//
//  TemarioDetailView.swift
//  opospeak
//
//  Created by David de León Acosta on 11/06/2026.
//

import SwiftUI
import SwiftData

struct TemarioDetailView: View {
    let temario: Temario

    @State private var busqueda = ""
    @State private var orden: TemaSortOrder = .natural
    @State private var mostrandoNuevoTema = false
    @State private var mostrandoAltaRapida = false

    private var temasVisibles: [Tema] {
        var temas = temario.temasActivos
        if !busqueda.isEmpty {
            temas = temas.filter { tema in
                String(tema.numero).contains(busqueda)
                    || (tema.titulo ?? "").localizedCaseInsensitiveContains(busqueda)
            }
        }
        return orden.sort(temas)
    }

    var body: some View {
        List {
            ForEach(temasVisibles) { tema in
                NavigationLink(value: tema) {
                    TemaRow(tema: tema)
                }
                .swipeActions(edge: .trailing) {
                    Button {
                        archivar(tema)
                    } label: {
                        Label("Archivar", systemImage: "archivebox")
                    }
                    .tint(.ambar)
                }
            }
        }
        .fondoEditorial()
        .navigationTitle(temario.nombre)
        .searchable(text: $busqueda, prompt: "Buscar por número o título")
        .toolbar {
            ToolbarItem(placement: .secondaryAction) {
                Picker("Ordenar", selection: $orden) {
                    ForEach(TemaSortOrder.allCases) { orden in
                        Text(orden.titulo).tag(orden)
                    }
                }
                .pickerStyle(.menu)
            }
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button {
                        mostrandoNuevoTema = true
                    } label: {
                        Label("Añadir tema", systemImage: "plus")
                    }
                    Button {
                        mostrandoAltaRapida = true
                    } label: {
                        Label("Crear temas del 1 al N", systemImage: "list.number")
                    }
                } label: {
                    Label("Añadir", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $mostrandoNuevoTema) {
            NuevoTemaSheet(temario: temario)
        }
        .sheet(isPresented: $mostrandoAltaRapida) {
            AltaRapidaSheet(temario: temario)
        }
        .overlay {
            if temario.temasActivos.isEmpty {
                ContentUnavailableView {
                    Label("Sin temas", systemImage: "list.bullet")
                } description: {
                    Text("Añade tus temas para empezar a practicar.")
                } actions: {
                    Button("Añadir tema") { mostrandoNuevoTema = true }
                        .buttonStyle(.borderedProminent)
                    Button("Crear temas del 1 al N") { mostrandoAltaRapida = true }
                }
            } else if temasVisibles.isEmpty {
                ContentUnavailableView.search(text: busqueda)
            }
        }
    }

    private func archivar(_ tema: Tema) {
        tema.activo = false
        tema.fechaActualizacion = .now
    }
}

private struct TemaRow: View {
    let tema: Tema

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .firstTextBaseline) {
                Text(tema.nombreVisible)
                    .font(.headline)
                if tema.titulo?.isEmpty == false {
                    Text("Tema \(tema.numero)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            HStack(spacing: 12) {
                Text("\(tema.intentoCount) intentos")
                if let fecha = tema.ultimaPractica {
                    Text("Último: \(fecha.formatted(date: .abbreviated, time: .omitted))")
                } else {
                    Text("Sin practicar")
                }
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
    }
}

struct NuevoTemaSheet: View {
    let temario: Temario

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var numero: Int = 1
    @State private var titulo = ""

    private var numeroDisponible: Bool {
        !temario.numerosExistentes.contains(numero)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Stepper(value: $numero, in: 1...9999) {
                        HStack {
                            Text("Número")
                            Spacer()
                            Text("\(numero)")
                                .foregroundStyle(numeroDisponible ? .secondary : Color.red)
                        }
                    }
                    .accessibilityLabel("Número de tema")
                    .accessibilityValue("\(numero)")
                } footer: {
                    if !numeroDisponible {
                        Text("Ya existe un tema con el número \(numero).")
                    }
                }
                Section("Opcional") {
                    TextField("Título", text: $titulo)
                        .accessibilityLabel("Título del tema")
                }
            }
            .navigationTitle("Nuevo tema")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Crear") { crear() }
                        .disabled(!numeroDisponible)
                }
            }
            .onAppear {
                numero = temario.siguienteNumeroLibre
            }
        }
    }

    private func crear() {
        let limpio = titulo.trimmingCharacters(in: .whitespacesAndNewlines)
        let tema = Tema(numero: numero, titulo: limpio.isEmpty ? nil : limpio, temario: temario)
        modelContext.insert(tema)
        dismiss()
    }
}

struct AltaRapidaSheet: View {
    let temario: Temario

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var desde = 1
    @State private var hasta = 25

    private var numerosACrear: [Int] {
        (try? TemaBulkCreator.plan(
            existingNumbers: temario.numerosExistentes,
            desde: desde,
            hasta: hasta
        )) ?? []
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Stepper(value: $desde, in: 1...9999) {
                        HStack {
                            Text("Desde")
                            Spacer()
                            Text("\(desde)").foregroundStyle(.secondary)
                        }
                    }
                    .accessibilityLabel("Primer número")
                    .accessibilityValue("\(desde)")
                    Stepper(value: $hasta, in: 1...9999) {
                        HStack {
                            Text("Hasta")
                            Spacer()
                            Text("\(hasta)").foregroundStyle(.secondary)
                        }
                    }
                    .accessibilityLabel("Último número")
                    .accessibilityValue("\(hasta)")
                } footer: {
                    Text(resumen)
                }
            }
            .navigationTitle("Alta rápida")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Crear \(numerosACrear.count)") { crear() }
                        .disabled(numerosACrear.isEmpty)
                }
            }
        }
    }

    private var resumen: String {
        if hasta < desde {
            return "El rango no es válido."
        }
        let existentes = (hasta - desde + 1) - numerosACrear.count
        if existentes > 0 {
            return "Se crearán \(numerosACrear.count) temas. Se omiten \(existentes) que ya existen."
        }
        return "Se crearán \(numerosACrear.count) temas sin título: Tema \(desde) … Tema \(hasta)."
    }

    private func crear() {
        for numero in numerosACrear {
            modelContext.insert(Tema(numero: numero, temario: temario))
        }
        dismiss()
    }
}

#Preview {
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
    container.mainContext.insert(Tema(numero: 2, titulo: "La Constitución", temario: temario))

    return NavigationStack {
        TemarioDetailView(temario: temario)
            .navigationDestination(for: Tema.self) { TemaDetailView(tema: $0) }
    }
    .modelContainer(container)
    .environment(AppEnvironment(modo: .local))
}
