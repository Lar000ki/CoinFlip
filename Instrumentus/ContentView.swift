import SwiftUI
import SceneKit


struct SceneKitView: UIViewControllerRepresentable {
    class Coordinator: NSObject, SCNSceneRendererDelegate {
        var parent: SceneKitView
        var sceneName: String?
        var isAnimating: Binding<Bool>
        var lastAnimated: Binding<Bool>
        var sceneView: SCNView?

        init(parent: SceneKitView, sceneName: String?, isAnimating: Binding<Bool>, lastAnimated: Binding<Bool>) {
            self.parent = parent
            self.sceneName = sceneName
            self.isAnimating = isAnimating
            self.lastAnimated = lastAnimated
        }
    }

    var sceneName: String?
    @Binding var isAnimating: Bool
    @Binding var lastAnimated: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self, sceneName: sceneName, isAnimating: $isAnimating, lastAnimated: $lastAnimated)
    }

    func makeUIViewController(context: Context) -> UIViewController {
            let viewController = UIViewController()
            let sceneView = SCNView(frame: .zero)
            viewController.view = sceneView

            // Load the Scene from the specified file
            if let sceneName = sceneName, let scene = SCNScene(named: sceneName) {
                sceneView.scene = scene
                sceneView.autoenablesDefaultLighting = false // Отключаем автоматическое освещение

                // Другие настройки сцены, если необходимо
            }

            sceneView.backgroundColor = UIColor.clear // Прозрачный фон

            sceneView.delegate = context.coordinator
            context.coordinator.sceneView = sceneView

            return viewController
        }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // Update the SceneKit scene if needed
        if let sceneView = context.coordinator.sceneView, let cylinderNode = sceneView.scene?.rootNode.childNode(withName: "cylinder2", recursively: true) {
            if isAnimating {
                //print(lastAnimated);
                if (lastAnimated == true) {
                    let resetAction = SCNAction.rotateTo(x: 0, y: 0, z: 0, duration: 0)
                    cylinderNode.runAction(resetAction)
                    //орел
                }else{
                    let resetAction = SCNAction.rotateTo(x: 110, y: 0, z: 0, duration: 0)
                    cylinderNode.runAction(resetAction)
                    //решка
                }
                // Rotate the node (you can adjust the parameters as needed)
                let rotateAction = SCNAction.rotateBy(x: 90, y: 0, z: 0, duration: 20.0)
                let repeatAction = SCNAction.repeatForever(rotateAction)
                cylinderNode.runAction(repeatAction)
            } else {
                cylinderNode.removeAllActions() // Stop the animation
            }
        }
    }
}

func delayWithSeconds(_ seconds: Double, completion: @escaping () -> ()) {
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
        completion()
    }
}

struct ContentView: View {
    @State private var resultText: String?
    @State private var isAnimating: Bool = false
    @State private var lastAnimated: Bool = false
    @State private var isFirstAppearance: Bool = true
    @State private var cylinderNode: SCNNode?
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                Color.clear
                VStack {
                        SceneKitView(sceneName: "coin.scn", isAnimating: $isAnimating, lastAnimated: $lastAnimated)
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                    
                    
                    if let resultText = resultText {
                        Text(isFirstAppearance ? "Heads or Tails?" : resultText)
                            .font(.title)
                    } else {
                        Text("Heads or Tails?")
                            .font(.title)
                    }
                    
                    Button("Flip the coin") {
                        flipCoin()
                    }
                    .disabled(isAnimating)
                    .font(.title)
                    .padding()
                    .background(Color.blue) // Фон кнопки
                    .foregroundColor(.white) // Цвет текста
                    .cornerRadius(10) // Закругление углов
                }
            }
        }
        .navigationTitle("Coin flip")
        .onAppear {
            isFirstAppearance = false
        }
    }

    private func flipCoin() {
        withAnimation {
            isAnimating.toggle()
            let rand = Bool.random();
            //let randomDelay = rand ? 1.4 : 2.1
            //let randomDelay = rand ? 2.1 : 1.4
            //1.4 тоже самое
            //2.1 другое
            var randomDelay: Double;
            if (lastAnimated == rand){
                randomDelay = 1.4;
            }else{
                randomDelay = 2.1;
            }
            delayWithSeconds(randomDelay) {
                isAnimating.toggle()
                resultText = rand ? "Heads" : "Tails"
                lastAnimated = rand;
                //print(lastAnimated, "flip")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
