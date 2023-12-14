//
//  ViewController.swift
//  SwiftyJSON_demo
//
//  Created by Peter van den Hamer on 12/12/2023.
//  Lightly modified version of Project38 by Paul Hudson, Hacking with Swift
//

import UIKit
import CoreData
import SwiftyJSON

let dataSourceURL: String = "https://api.github.com/repos/apple/swift/commits?per_page=100"

class ViewController: UITableViewController {
    var container: NSPersistentContainer!
    var githubCommits = [Commit]()
    var githubCommitPredicate: NSPredicate?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Filter",
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(changeFilter))

        container = NSPersistentContainer(name: "SwiftyJSON_demo") // name of SQLite database

        container.loadPersistentStores { _, error in // load or create database
            self.container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            if let error = error {
                print("Unresolved error \(error)")
            }
        }

        // https://www.hackingwithswift.com/read/38/4/creating-an-nsmanagedobject-subclass-with-xcode
        performSelector(inBackground: #selector(fetchNewGithubCommits), with: nil)

        loadRecordsFromDatabase()
    }

    // MARK: - UITableView table mechanics

    // there is only one section
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    // return records in a numbered section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return githubCommits.count
    }

    // render cell at IndexPath
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Commit", for: indexPath)

        let githubCommit = githubCommits[indexPath.row]
        cell.textLabel!.text = githubCommit.message
        cell.detailTextLabel!.text = """
                                     By \(githubCommit.author?.name ?? "Missing author") \
                                     on \(githubCommit.date!.description)
                                     """
        return cell
    }

    // navigate to detail view
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vController = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            vController.detailItem = githubCommits[indexPath.row]
            navigationController?.pushViewController(vController, animated: true)
        }
    }

    // delete a table row
    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let commit = githubCommits[indexPath.row] // selected record
            container.viewContext.delete(commit) // remove from ManagedObjectContext
            githubCommits.remove(at: indexPath.row) // remove from our own array
            tableView.deleteRows(at: [indexPath], with: .fade) // remove from UI (why is this done manually?)

            saveRecordsToDatabase(count: githubCommits.count)
        }
    }

    // MARK: - predicate stuff

    @objc func changeFilter() {
        let alertCtrl = UIAlertController(title: "Filter commits…", message: nil, preferredStyle: .actionSheet)
        alertCtrl.popoverPresentationController?.sourceItem = navigationItem.rightBarButtonItem // for iPadOS

        alertCtrl.addAction(UIAlertAction(title: "Show only fixes", style: .default) { [unowned self] _ in
            githubCommitPredicate = NSPredicate(format: "message CONTAINS[c] 'fix'")
            loadRecordsFromDatabase()
        })
        alertCtrl.addAction(UIAlertAction(title: "Ignore Pull Requests", style: .default) { [unowned self] _ in
            githubCommitPredicate = NSPredicate(format: "NOT message BEGINSWITH 'Merge pull request'")
            loadRecordsFromDatabase()
        })
        alertCtrl.addAction(UIAlertAction(title: "Show only recent", style: .default) { [unowned self] _ in
            let twelveHoursAgo = Date().addingTimeInterval(-43200)
            githubCommitPredicate = NSPredicate(format: "date > %@", twelveHoursAgo as NSDate)
            loadRecordsFromDatabase()
        })
        alertCtrl.addAction(UIAlertAction(title: "Show only DougGregor commits", style: .default) { [unowned self] _ in
            self.githubCommitPredicate = NSPredicate(format: "author.name == 'Doug Gregor'")
            self.loadRecordsFromDatabase()
        })
        alertCtrl.addAction(UIAlertAction(title: "Show all commits", style: .default) { [unowned self] _ in
            githubCommitPredicate = nil
            loadRecordsFromDatabase()
        })

        alertCtrl.addAction(UIAlertAction(title: "Cancel", style: .cancel)) // automatically hidden on iPad
        present(alertCtrl, animated: true)
    }

    // MARK: - moving data around

    func loadRecordsFromDatabase() {
        let request = Commit.createFetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        request.predicate = githubCommitPredicate

        do {
            githubCommits = try container.viewContext.fetch(request)
            print("Fetching \(githubCommits.count) records from CoreData database.")
            tableView.reloadData()
        } catch {
            fatalError("FATAL: Fetching records from CoreData database failed")
        }
    }

    func saveRecordsToDatabase(count: Int) { // count is only for print() statement
        let context: NSManagedObjectContext = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
                print("Succesfully saved \(count) records to CoreData database")
            } catch {
                fatalError("An error occurred while saving to CoreData database: \(error)")
            }
        } else {
            print("There were no changes to save to CoreData database")
        }
    }

    @objc func fetchNewGithubCommits() {
        let newestGithubCommitDate = getNewestGithubCommitDate()
        let urlSuffix: String = "&since=\(newestGithubCommitDate)"

        if let data = try? String(contentsOf: URL(string: dataSourceURL + urlSuffix)!) {
            // give the data to SwiftyJSON to parse
            let jsonGithubCommits = JSON(parseJSON: data) // call to SwiftyJSON

            // read the commits back out
            let jsonGithubCommitArray = jsonGithubCommits.arrayValue

            print("Received \(jsonGithubCommitArray.count) records from Github server.")

            DispatchQueue.main.async { [unowned self] in
                for jsonGithubCommit in jsonGithubCommitArray {
                    let commit = Commit(context: self.container.viewContext) // create Commit object commit
                    self.fillCommitFields(commit: commit, usingJSON: jsonGithubCommit) // assign Commit properties
                }

                saveRecordsToDatabase(count: jsonGithubCommitArray.count)
                loadRecordsFromDatabase()
            }
        } else {
            fatalError("Please check URL \(dataSourceURL)")
        }
    }

    private func getNewestGithubCommitDate() -> String {
        let formatter = ISO8601DateFormatter()

        let newestFetchRequest = Commit.createFetchRequest()
        newestFetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        newestFetchRequest.fetchLimit = 1 // only fetch max 1 most recent record

        if let commits = try? container.viewContext.fetch(newestFetchRequest) {
            if commits.count > 0, commits[0].date != nil { // fixed optional bug in original code
                return formatter.string(from: commits[0].date!.addingTimeInterval(1))
            }
        }

        return formatter.string(from: Date(timeIntervalSince1970: 0))
    }

    // swiftlint:disable line_length
    /* example of input for configure(). • means JSON tree has been partly collapsed.
     [
       {
         "sha": "0ec84e7bce414ac67cd7edf03aa7971a54813547",
         "node_id": "C_kwDOAqwwJdoAKDBlYzg0ZTdiY2U0MTRhYzY3Y2Q3ZWRmMDNhYTc5NzFhNTQ4MTM1NDc",
         "commit": {
           "author": {•},
           "committer": {•},
           "message": "Merge pull request #70214 from xedin/rdar-119040159\n\n[CSBindings] Extend early array literal favoring to cover dictionaries",
           "tree": {•},
           "url": "https://api.github.com/repos/apple/swift/git/commits/0ec84e7bce414ac67cd7edf03aa7971a54813547",
           "comment_count": 0,
           "verification": {•}
         },
         "url": "https://api.github.com/repos/apple/swift/commits/0ec84e7bce414ac67cd7edf03aa7971a54813547",
         "html_url": "https://github.com/apple/swift/commit/0ec84e7bce414ac67cd7edf03aa7971a54813547",
         "comments_url": "https://api.github.com/repos/apple/swift/commits/0ec84e7bce414ac67cd7edf03aa7971a54813547/comments",
         "author": {•},
         "committer": {•},
         "parents": [•]
       }
     ]
    */
    // swiftlint:enable line_length

    func fillCommitFields(commit: Commit, usingJSON json: JSON) {
        commit.sha = json["sha"].stringValue
        commit.message = json["commit"]["message"].stringValue
        commit.url = json["html_url"].stringValue

        let formatter = ISO8601DateFormatter()
        commit.date = formatter.date(from: json["commit"]["committer"]["date"].stringValue) ?? Date()

        var commitAuthor: Author!

        // see if this author exists already
        let authorRequest = Author.createFetchRequest()
        authorRequest.predicate = NSPredicate(format: "name == %@", json["commit"]["committer"]["name"].stringValue)

        if let authors = try? container.viewContext.fetch(authorRequest) {
            if authors.count > 0 {
                // we have this author already
                commitAuthor = authors[0]
            }
        }

        if commitAuthor == nil {
            // we didn't find a saved author - create a new one!
            let author = Author(context: container.viewContext)
            author.name = json["commit"]["committer"]["name"].stringValue
            author.email = json["commit"]["committer"]["email"].stringValue
            commitAuthor = author
        }

        // use the author, either saved or new
        commit.author = commitAuthor
    }

}
