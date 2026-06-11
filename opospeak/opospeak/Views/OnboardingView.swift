//
//  OnboardingView.swift
//  opospeak
//
//  Created by David de León Acosta on 11/06/2026.
//

import SwiftUI
import SwiftData

// Primer arranque (define-onboarding-flow): no enseña la aplicación,
// lleva al usuario a su primera práctica cuanto antes. Tres fases, todas
// abandonables; lo creado en fases completadas persiste.
struct OnboardingView: View {

    /// Se invoca al completar el flujo con el temario creado, para que
    /// ContentView navegue directamente a su lista de temas.
    let alCompletar: (Temario) -> Void

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    private enum Fase {
        case bienvenida
        case nombreTemario
        case temas
    }

    @State private var fase: Fase = .bienvenida
    @State private var nombre = ""
    @State private var cantidad = 25
    @State private var temarioCreado: Temario?

    private static let ejemplos = ["Judicatura", "Notarías", "Inspección de Hacienda"]
    private static let atajos = [25, 50, 100, 200, 325]

    var body: some View {
        NavigationStack {
            switch fase {
            case .bienvenida:
                bienvenida
            case .nombreTemario:
                nombreTemario
            case .temas:
                temas
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
                fase = .nombreTemario
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

    // MARK: - Fase 2: primer temario

    private var nombreValido: Bool {
        !nombre.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var nombreTemario: some View {
        Form {
            Section {
                TextField("Nombre de tu temario", text: $nombre)
                    .accessibilityLabel("Nombre del temario")
            } header: {
                Text("Tu primer temario")
            } footer: {
                Text("Solo necesitas el nombre. Todo lo demás puede esperar.")
            }

            Section("Sugerencias") {
                ForEach(Self.ejemplos, id: \.self) { ejemplo in
                    Button(ejemplo) {
                        nombre = ejemplo
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
                .disabled(!nombreValido)
            }
        }
    }

    // MARK: - Fase 3: temas

    private var temas: some View {
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
        .navigationTitle(nombre)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Acciones

    /// El temario se persiste al salir de la fase 2: si el usuario
    /// abandona después, su trabajo se conserva.
    private func crearTemario() {
        let limpio = nombre.trimmingCharacters(in: .whitespacesAndNewlines)
        let temario = Temario(nombre: limpio)
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
        for: Temario.self, Tema.self, Sesion.self, Intento.self,
        Grabacion.self, Metrica.self, Nota.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    return OnboardingView { _ in }
        .modelContainer(container)
}
