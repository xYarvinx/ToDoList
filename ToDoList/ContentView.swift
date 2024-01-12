import SwiftUI
import SwiftData

struct Task: Codable, Identifiable {
    var id = UUID()
    var title: String
    var isCompleted = false
}

class TaskStore: ObservableObject {
    @Published var tasks = [Task]()
    
    init() {
        if let savedTasks = UserDefaults.standard.data(forKey: "tasks"),
           let decodedTasks = try? JSONDecoder().decode([Task].self, from: savedTasks) {
            tasks = decodedTasks
        }
    }
    
    func addTask(title: String) {
        guard !title.isEmpty else { return }
        
        let newTask = Task(title: title)
        tasks.append(newTask)
        saveTasks()
    }
    
    func removeTask(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
        saveTasks()
    }
    
    func toggleTaskCompletion(task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isCompleted.toggle()
            saveTasks()
        }
    }
    
    private func saveTasks() {
        if let encodedTasks = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(encodedTasks, forKey: "tasks")
        }
    }
}

struct ContentView: View {
    @ObservedObject var taskStore = TaskStore()
    @State private var newTaskTitle = ""
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Новая задача")) {
                    HStack {
                        TextField("Введите новую задачу", text: $newTaskTitle)
                        Button(action: {
                            taskStore.addTask(title: newTaskTitle)
                            newTaskTitle = ""
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title)
                        }
                    }
                }
                
                Section(header: Text("Мои задачи")) {
                    ForEach(taskStore.tasks) { task in
                        HStack {
                            Button(action: {
                                taskStore.toggleTaskCompletion(task: task)
                            }) {
                                Image(systemName: task.isCompleted ? "checkmark.square.fill" : "square")
                                    .foregroundColor(task.isCompleted ? .green : .primary)
                            }
                            Text(task.title)
                                .strikethrough(task.isCompleted)
                            Spacer()
                        }
                    }
                    .onDelete(perform: taskStore.removeTask) 
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle("Список задач")
            .navigationBarItems(trailing: EditButton())
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
