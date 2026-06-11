//
//  OnboardingView.swift
//  opospeak
//
//  Created by David de León Acosta on 11/06/2026.
//

import SwiftUI
import SwiftData

// Primer arranque (define-onboarding-flow): no enseña la aplicación,
// lleva al usuario a su primera práctica cuanto antes. Cuatro fases con
// la jerarquía correcta — oposición (Judicatura) → temario (Civil) →
// temas — todas abandonables; lo creado en fases completadas persiste.
struct OnboardingView: View {

    /// Se invoca al completar el flujo con el temario creado, para que
    /// ContentView navegue directamente a su lista de temas.
    let alCompletar: (Temario) -> Void

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    private enum Fase {
        case bienvenida
        case nombreOposicion
        case nombreTemario
        case temas
    }

    @State private var fase: Fase = .bienvenida
    @State private var nombreOposicion = ""
    @State private var nombreTemario = ""
    @State private var cantidad = 25
    @State private var oposicionCreada: Oposicion?
    @State private var temarioCreado: Temario?

    private static let ejemplosOposicion = ["Judicatura", "Notarías", "Inspección de Hacienda"]
    private static let ejemplosTemario = ["Civil", "Penal", "Procesal"]
    private static let atajos = [25, 50, 100, 200, 325]

    var body: some View {
        NavigationStack {
            switch fase {
            case .bienvenida:
                bienvenida
            case .nombreOposicion:
                nombreOposicionFase
            case .nombreTemario:
                nombreTemarioFase
            case .temas:
                temasFase
            }
        }
    }

    // MARK: - Fase 1: bienvenida

    private var bienvenida: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "mic.circle")
                .font(.system(size: 72))
                .foregroundStyle(Color.tinta)
                .accessibilityHidden(true)

            Text("OpoSpeak")
                .font(.largeTitle.bold())

            Text("Tu historial completo de práctica oral: organiza tus temas, graba tus intentos y observa tu evolución a lo largo de los años.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 32)

            Label("Tus datos son privados y viven en tu dispositivo.", systemImage: "lock.shield")
                .font(.footnote)
                .foregroundStyle(.secondary)

            Spacer()

            Button {
                fase = .nombreOposicion
            } label: {
                Text("Empezar")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.horizontal)
            .padding(.bottom)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.papel)
    }

    // MARK: - Fase 2: oposición

    private var nombreOposicionValido: Bool {
        !nombreOposicion.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var nombreOposicionFase: some View {
        Form {
            Section {
                TextField("Nombre de tu oposición", text: $nombreOposicion)
                    .accessibilityLabel("Nombre de la oposición")
            } header: {
                Text("¿Qué oposición preparas?")
            } footer: {
                Text("Dentro de tu oposición organizarás tus temarios: Civil, Penal, bloques…")
            }

            Section("Sugerencias") {
                ForEach(Self.ejemplosOposicion, id: \.self) { ejemplo in
                    Button(ejemplo) {
                        nombreOposicion = ejemplo
                    }
                    .accessibilityHint("Rellena el nombre con \(ejemplo)")
                }
            }
        }
        .navigationTitle("Tu oposición")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Continuar") {
                    crearOposicion()
                }
                .disabled(!nombreOposicionValido)
            }
        }
    }

    // MARK: - Fase 3: primer temario

    private var nombreTemarioValido: Bool {
        !nombreTemario.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var nombreTemarioFase: some View {
        Form {
            Section {
                TextField("Nombre del temario", text: $nombreTemario)
                    .accessibilityLabel("Nombre del temario")
            } header: {
                Text("Tu primer temario de \(nombreOposicion)")
            } footer: {
                Text("Solo necesitas el nombre. Podrás crear más temarios después.")
            }

            Section("Sugerencias") {
                ForEach(Self.ejemplosTemario, id: \.self) { ejemplo in
                    Button(ejemplo) {
                        nombreTemario = ejemplo
                    }
                    .accessibilityHint("Rellena el nombre con \(ejemplo)")
                }
            }
        }
        .navigationTitle("Crea tu temario")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Continuar") {
                    crearTemario()
                }
                .disabled(!nombreTemarioValido)
            }
        }
    }

    // MARK: - Fase 4: temas

    private var temasFase: some View {
        Form {
            Section {
                Stepper(value: $cantidad, in: 1...TemaBulkCreator.maximoTemas) {
                    HStack {
                        Text("Temas")
                        Spacer()
                        Text("\(cantidad)").foregroundStyle(.secondary)
                    }
                }
                .accessibilityLabel("Número de temas")
                .accessibilityValue("\(cantidad)")
            } header: {
                Text("¿Cuántos temas tiene tu temario?")
            } footer: {
                Text("Se crearán como Tema 1, Tema 2… Podrás añadir títulos cuando quieras.")
            }

            Section {
                HStack {
                    ForEach(Self.atajos, id: \.self) { atajo in
                        Button("\(atajo)") {
                            cantidad = atajo
                        }
                        .buttonStyle(.bordered)
                        .frame(maxWidth: .infinity)
                    }
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
            }

            Section {
                Button {
                    crearTemasYTerminar()
                } label: {
                    Text("Crear \(cantidad) temas")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }

                Button("Prefiero añadirlos después") {
                    terminar()
                }
                .foregroundStyle(.secondary)
            }
        }
        .navigationTitle(nombreTemario)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Acciones

    /// Cada artefacto se persiste al salir de su fase: si el usuario
    /// abandona después, su trabajo se conserva.
    private func crearOposicion() {
        let limpio = nombreOposicion.trimmingCharacters(in: .whitespacesAndNewlines)
        let oposicion = Oposicion(nombre: limpio)
        modelContext.insert(oposicion)
        oposicionCreada = oposicion
        fase = .nombreTemario
    }

    private func crearTemario() {
        guard let oposicion = oposicionCreada else { return }
        let limpio = nombreTemario.trimmingCharacters(in: .whitespacesAndNewlines)
        let temario = Temario(nombre: limpio, oposicion: oposicion)
        modelContext.insert(temario)
        temarioCreado = temario
        fase = .temas
    }

    private func crearTemasYTerminar() {
        guard let temario = temarioCreado else { return }
        let numeros = (try? TemaBulkCreator.plan(
            existingNumbers: temario.numerosExistentes,
            desde: 1,
            hasta: cantidad
        )) ?? []
        for numero in numeros {
            modelContext.insert(Tema(numero: numero, temario: temario))
        }
        terminar()
    }

    private func terminar() {
        guard let temario = temarioCreado else {
            dismiss()
            return
        }
        try? modelContext.save()
        alCompletar(temario)
        dismiss()
    }
}

#Preview {
    let container = try! ModelContainer(
        for: Oposicion.self, Temario.self, Tema.self, Sesion.self, Intento.self,
        Grabacion.self, Metrica.self, Nota.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    return OnboardingView { _ in }
        .modelContainer(container)
}
