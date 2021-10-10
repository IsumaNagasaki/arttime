use std::collections::HashMap;
use std::collections::HashSet;
use std::sync::atomic::{AtomicU32, Ordering};
use std::sync::Arc;

use async_std::sync::RwLock;
use tide::convert::{Deserialize, Serialize};
use tide::utils::After;
use tide::Response;

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
struct Challenge {
    title: String,
    description: String,
    image_url: String,
    author_contact: String,
    category: String,
    start: Option<String>,
    end: Option<String>,
}

type Username = String;
type Password = String;
pub type ChallengeId = u32;
type Credentials = (Username, Password);

#[derive(Debug, Clone, Default)]
pub struct State {
    users: Arc<RwLock<HashSet<Credentials>>>,
    challenges: Arc<RwLock<HashMap<ChallengeId, Challenge>>>,
    next_challenge_id: Arc<AtomicU32>,
}

impl State {
    async fn has_credentials(&self, credentials: &Credentials) -> bool {
        self.users.read().await.contains(credentials)
    }

    async fn register_user(&self, credentials: Credentials) {
        self.users.write().await.insert(credentials);
    }

    async fn challenges(&self) -> Vec<Challenge> {
        self.challenges.read().await.values().cloned().collect()
    }

    async fn add_challenge(&self, challenge: Challenge) -> ChallengeId {
        let id = self.next_challenge_id.fetch_add(1, Ordering::SeqCst);
        self.challenges.write().await.insert(id, challenge);
        id
    }
}

#[async_std::test]
async fn challenge_id_incremented_correctly() {
    let state = State::default();
    assert_eq!(0, state.next_challenge_id.load(Ordering::SeqCst));
    let id = state.add_challenge(Challenge::default()).await;
    assert_eq!(0, id);
    assert_eq!(1, state.next_challenge_id.load(Ordering::SeqCst))
}

#[async_std::main]
async fn main() -> tide::Result<()> {
    let mut app = tide::with_state(State::default());
    app.at("/health").get(|_| async { Ok("Healthy") });
    app.at("/login").get(handler::login);
    app.at("/register").post(handler::register);
    app.at("/challenge/all").get(handler::all_challenges);
    app.at("/challenge/add").post(handler::add);
    app.with(After(|mut res: Response| async {
        if let Some(err) = res.error() {
            let msg = format!("Error: {}", err);
            println!("{}", msg);
            res.set_body(msg);
        }
        Ok(res)
    }));
    app.listen("0.0.0.0:8080").await?;
    Ok(())
}

mod auth {
    use tide::Request;

    use crate::{Credentials, State};

    const USER_HEADER: &str = "Username";
    const PASSWORD_HEADER: &str = "Password";

    pub fn parse_headers(req: &Request<State>) -> Result<Credentials, String> {
        let username = req
            .header(USER_HEADER)
            .ok_or(format!("{} header unspecified", USER_HEADER))?
            .last()
            .as_str();
        let password = req
            .header(PASSWORD_HEADER)
            .ok_or(format!("{} header unspecified", PASSWORD_HEADER))?
            .last()
            .as_str();
        Ok((username.to_owned(), password.to_owned()))
    }

    pub async fn check(req: &Request<State>) -> Result<(), tide::Error> {
        let credentials = parse_headers(req)
            .map_err(|err| tide::Error::from_str(tide::StatusCode::BadRequest, err))?;
        if req.state().has_credentials(&credentials).await {
            Ok(())
        } else {
            Err(tide::Error::from_str(
                tide::StatusCode::Unauthorized,
                "User is not registered.",
            ))
        }
    }
}

mod handler {
    use tide::convert::json;
    use tide::Body;
    use tide::Request;
    use tide::Response;

    use crate::auth;
    use crate::Challenge;
    use crate::State;

    pub async fn login(req: Request<State>) -> tide::Result {
        auth::check(&req).await?;
        Ok(Response::new(tide::StatusCode::Ok))
    }

    pub async fn register(req: Request<State>) -> tide::Result {
        if auth::check(&req).await.is_ok() {
            Err(tide::Error::from_str(
                tide::StatusCode::BadRequest,
                "User already registered.",
            ))
        } else {
            let credentials = auth::parse_headers(&req)
                .map_err(|err| tide::Error::from_str(tide::StatusCode::BadRequest, err))?;
            req.state().register_user(credentials).await;
            Ok(Response::new(tide::StatusCode::Ok))
        }
    }

    pub async fn add(mut req: Request<State>) -> tide::Result<Body> {
        let challenge: Challenge = req.body_json().await?;
        let id = req.state().add_challenge(challenge).await;
        Ok(Body::from_json(&json!({ "id": id })).unwrap())
    }

    pub async fn all_challenges(req: Request<State>) -> tide::Result<Body> {
        let challenges = req.state().challenges().await;
        Ok(Body::from_json(&json!({ "challenges": challenges })).unwrap())
    }
}
