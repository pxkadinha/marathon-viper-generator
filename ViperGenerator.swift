import Foundation
import Files

var moduleName : String?

struct FilesGenerator {
    
    let viewName, presenterName, wireframeName, interactorName, dataManagerName, contractName: String
    let viewFile, presenterFile, wireframeFile, interactorFile, dataManagerFile, contractFile : File
    
    let folder: Folder
    
    
    init(moduleName: String) throws {
        
        viewName = moduleName + "Controller"
        presenterName = moduleName + "Presenter"
        wireframeName = moduleName + "Wireframe"
        interactorName = moduleName + "Interactor"
        dataManagerName = moduleName + "DataManager"
        contractName = moduleName + "Contract"
        
        folder = try FileSystem().currentFolder.createSubfolder(named: moduleName)
        
        viewFile = try folder.createSubfolder(named: "ViewController").createFile(named: viewName + ".swift")
        presenterFile = try folder.createSubfolder(named: "Presenter").createFile(named: presenterName + ".swift")
        interactorFile = try folder.createSubfolder(named: "Interactor").createFile(named: interactorName + ".swift")
        wireframeFile = try folder.createSubfolder(named: "Wireframe").createFile(named: wireframeName + ".swift")
        contractFile = try folder.createFile(named: contractName + ".swift")
        
        let dataManagerFolder = try folder.createSubfolder(named: "DataManager")
        dataManagerFile = try dataManagerFolder.createSubfolder(named: "Remote").createFile(named: dataManagerName + ".swift")
        try dataManagerFolder.createSubfolder(named: "Local")
        
    }
    
    
    func generate() throws {
        
        guard let moduleName = moduleName else { return }
        
        try createContract(moduleName: moduleName)
        try createWireframe(moduleName: moduleName)
        try createView(moduleName: moduleName)
        try createPresenter(moduleName: moduleName)
        try createInteractor(moduleName : moduleName)
        try createDataManager(moduleName: moduleName)
    }
    
    
    private func createContract(moduleName : String) throws {
        
        try contractFile.write(string: """
            
            protocol \(moduleName)WireframeProtocol : class {
                static func start() -> UIViewController
            }
            
            protocol \(moduleName)ViewProtocol : class {
                var presenter : \(moduleName)PresenterProtocol? { get set }
            }
            
            protocol \(moduleName)PresenterProtocol : class {
                var view : \(moduleName)ViewProtocol? { get set }
                var wireframe : \(moduleName)WireframeProtocol? { get set }
                var interactor : \(moduleName)InteractorInputProtocol? { get set }
            
                func viewDidLoad() {
            
                }
            }
            
            protocol \(moduleName)InteractorInputProtocol : class {
                var presenter : \(moduleName)InteractorOutputProtocol? { get set }
                var dataManager : \(moduleName)DataManagerInputProtocol? { get set }
            }
            
            protocol \(moduleName)InteractorOutputProtocol : class {
            
            }
            
            protocol \(moduleName)DataManagerInputProtocol : class {
                var requestHandler : \(moduleName)DataManagerOutputProtocol? { get set }
            }
            
            protocol \(moduleName)DataManagerOutputProtocol : class {
            
            }
            """)
    }
    
    private func createWireframe(moduleName : String) throws {
        
        try wireframeFile.write(string: """
            import UIKit
            
            class \(moduleName)Wireframe : \(moduleName)WireframeProtocol {
                class func start() -> UIViewController {
                    let vc : //TODO instantiate your view controller
            
                    let presenter : \(moduleName)PresenterProtocol & \(moduleName)InteractorOutputProtocol = \(moduleName)Presenter()
                    let interactor : \(moduleName)InteractorInputProtocol & \(moduleName)DataManagerOutputProtocol = \(moduleName)Interactor()
                    let dataManager : \(moduleName)DataManagerInputProtocol = \(moduleName)DataManager()
                    let wireframe : \(moduleName)WireframeProtocol = \(moduleName)Wireframe
            
                    vc.presenter = presenter
            
                    presenter.view = vc
                    presenter.wireframe = wireframe
                    presenter.interactor = interactor
            
                    interactor.presenter = presenter
                    interactor.dataManager = dataManager
            
                    dataManager.requestHandler = interactor
            
                    return vc
                }
            }
            
            """)
    }
    
    private func createView(moduleName : String) throws {
        
        try viewFile.write(string: """
            import UIKit
            
            class \(moduleName)ViewController : UIViewController {
            
                var presenter : \(moduleName)PresenterProtocol?
            
                override func viewDidLoad() {
                    super.viewDidLoad()
            
                    //presenter?.viewDidLoad()
                }
            }
            
            
            extension \(moduleName)ViewController : \(moduleName)ViewProtocol {
            
            }
            """)
    }
    
    private func createPresenter(moduleName : String) throws {
        
        try presenterFile.write(string: """
            
            class \(moduleName)Presenter : \(moduleName)PresenterProtocol {
            
                weak var view : \(moduleName)ViewProtocol?
                var interactor : \(moduleName)InputProtocol?
                var wireframe : \(moduleName)WireframeProtocol?
            
                /*func viewDidLoad() {
            
                }*/
            }
            
            extension \(moduleName)Presenter : \(moduleName)InteractorOutputProtocol {
            
            }
            """)
    }
    
    private func createInteractor(moduleName : String) throws {
        
        try interactorFile.write(string: """
            class \(moduleName)Interactor : \(moduleName)InteractorInputProtocol {
            
                var presenter : \(moduleName)InteractorOutputProtocol?
                var dataManager : \(moduleName)DataManagerInputProtocol?
            
            }
            
            extension \(moduleName)Interactor : \(moduleName)DataManagerOutputProtocol {
            
            }
            """)
        
    }
    
    private func createDataManager(moduleName : String) throws {
        try dataManagerFile.write(string: """
            class \(moduleName)DataManager : \(moduleName)DataManagerInputProtocol {
            
                var requestHandler : \(moduleName)DataManagerOutputProtocol?
            
            }
            
            """)
    }
    
}

if CommandLine.argc < 2 {
    print("Not argument passed")
} else {
    moduleName = CommandLine.arguments[1]
    let fileGenerator = try FilesGenerator(moduleName: moduleName!)
    try fileGenerator.generate()
}
